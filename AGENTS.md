# AGENTS.md — helm-charts repo context

Purpose: this is an "infrared"-style GitOps Helm monorepo, deployed via ArgoCD
App-of-Apps (`charts/environment` + `charts/environments`). Read this before
adding/editing any chart.

## Repo layout
```
charts/
  <highlevel-chart>/         # deployable "stack" chart (postgres, konghq, gitlab, ...)
  chart_deps/<domain>/<dep>/ # reusable dependency charts, grouped by domain
    app/core                 #   library chart: shared resource templates (_*.tpl)
    app/common               #   generic app chart built from core (deployment/sts/etc.)
    postgres|redis|rabbitmq|prometheus|grafana|fluent|konghq|security|blockchain
  environment/                # per-env ArgoCD Application generator (chart_apps, crds, manifests)
  environments/                # generates one `environment` Application per env + root app
  globals.yaml                 # shared `global.*` defaults injected into every Application's values
crds/<operator>/               # raw CRD yaml + update.sh fetch script, applied via environment/crds.yaml
scripts/gcloud/                 # infra helper scripts
```

- **Highlevel chart** = a service/stack. Its `Chart.yaml` `dependencies` list is a
  subset of `chart_deps/*` charts (local, `repository: file://../chart_deps/...`)
  plus optionally upstream/OCI charts (bitnami, prometheus-community, gitlab, etc).
  Every dependency has `condition: <alias>.enabled` and usually an `alias:`.
- **chart_deps** charts are never deployed standalone; they're building blocks.
  Group by domain folder (e.g. `chart_deps/postgres/postgres-cluster`).
- `charts/core` (`chart_deps/app/core`) is a **library chart** (`type: library`,
  no rendered templates) with reusable partials: `_deployment.tpl`,
  `_statefulset.tpl`, `_service.tpl`, `_ingress.tpl` (`core.ingress`), `_pvc.tpl`,
  `_pv.tpl`, `_secret.tpl`, `_job.tpl`, `_role.tpl`, `_clusterrole.tpl`, `_sa.tpl`,
  `_podTemplate.tpl`, plus `_helpers.tpl` with:
  - `core.obj.enricher` — defaults `namespace` (Release.Namespace) and `enabled` (true) on an object.
  - `core.labels.constructor` — merges chart labels + `.Values.labels` (global) + object-level `.labels`.
  Any chart that needs a generic resource (ingress, deployment, secret, ...)
  should depend on `core` and call these templates rather than hand-rolling yaml.
- `chart_deps/app/common` is a full generic-app chart built on `core` (deployment,
  statefulset, service, ingress, hpa, pvc/pv, rbac, serviceaccount, secret,
  servicemonitor, job, additionalservices) — reuse it for simple apps instead of
  writing a new chart from scratch when possible.
- **Own resources over subchart magic**: when wrapping a large upstream chart
  (gitlab, kube-prometheus-stack, thanos, redis-operator, ...), disable its
  built-in bundled sub-components (postgres/redis/ingress/cert-manager/etc.) via
  values and instead attach our own `chart_deps` resources (own postgres-cluster,
  own ingress via `core.ingress`, own prometheus-rules/servicemonitor/podmonitor).
  See `charts/gitlab/values.yaml` for the canonical example (`postgresql.install:
  false`, `redis.install: false`, `installCertmanager: false`, own
  `postgres-gitlab` / `redis-gitlab` / `ingresses.webservice` instead).

## Standard chart structure (every chart should follow this)
```
<chart>/
  Chart.yaml       # apiVersion: v2, name, version (0.1.0 for internal charts,
                    # bump on changes), dependencies with alias+condition
  Chart.lock        # committed; charts/*.tgz vendored deps also committed
  values.yaml        # values.yaml with sane defaults, `enabled: false` for
                     # optional deps, comments for cross-cutting notes
  templates/
    _helpers.tpl      # <chart>.name / .fullname / .chart / .labels / .selectorLabels
                       # (copy of the standard Helm boilerplate, prefixed with chart name)
    ingresses.yaml     # `range .Values.ingresses` -> `core.ingress` (see charts/gitlab, charts/prometheus)
    <resource>.yaml    # one file per resource kind, plural/kebab named
```
Observability sidecar convention used across `chart_deps` (postgres-cluster,
prometheus-operated, alertmanager-operated, ...): optional `podMonitor`/
`servicemonitor`, `prometheus-rules` (with `PrometheusAlerts.*.AbsentMetricCritical`),
and `fluentbit` log shipping, each gated by its own `.enabled` + `condition:` in Chart.yaml.

## Naming & values conventions
- Dependency alias = `<name>-<purpose>`, e.g. `postgres-gitlab`, `redis-gitlab`,
  `prometheus-main`, `alertmanager-main`. Top-level values key must match the alias.
- `global.*` values (company, domain, env, cloud, ingress.class, access, alerts,
  bucket, registry) come from `charts/globals.yaml` and are injected by
  `charts/environment` into every ArgoCD Application — don't redefine them per
  chart, only read `.Values.global.*`.
- Anything user-facing but environment-specific must have a `# SET THIS:` comment
  in values.yaml (see `charts/gitlab/values.yaml`).
- Ingress: define under a top-level `ingresses:` map (name -> ingress spec with
  `name`, `service.name/port`, `className`, `annotations`, `hosts`, `tls`), rendered
  via `templates/ingresses.yaml` looping and calling `core.ingress`. Values commonly
  use `{{ ... }}` Go-template strings evaluated with `tpl` inside the templates
  (e.g. `"gl.{{ .Values.global.company.domain.env }}"`).
- Kubernetes version compat is handled inside `core.ingress` (networking.k8s.io
  v1/v1beta1/extensions fallback) — don't duplicate that logic per chart.

## ArgoCD wiring (`charts/environment`, `charts/environments`)
- One ArgoCD `Application` per entry in `environment`'s `.Values.chart_apps.<name>`;
  path defaults to `charts/<name>` (or `charts/app/<name>` if `app: true`), values
  come from `globals.yaml` + `environments/<env>/<name>/values.yaml`.
- `crds.operators.<name>.enabled` wires `crds/<name>` similarly.
- `manifests` wires raw manifest directories per env.
- When adding a new highlevel chart meant to be deployed, add a matching entry to
  `charts/environment/values.yaml` `chart_apps` (mirrors existing entries like
  `gitlab`, `postgres`, `konghq`).

## Repo hygiene
- Pre-commit: `yamllint` (relaxed, 2-space indent, templates/*.yaml excluded).
  Run `pre-commit install` after cloning; `pip install pre-commit` first.
- Root `CHANGELOG.md` tracks every release with sections: `BreakingChanges`,
  `New features`, `Enhancements`, `Fixes`, grouped by chart name. Update it for
  non-trivial changes.
- Vendored/local dependency `.tgz` archives under `charts/**/charts/` are
  committed to git — after changing a local dependency (e.g. `core`), run
  `helm dependency update` in every chart that (transitively) depends on it and
  commit the regenerated `.tgz` (Helm does not do this recursively — see
  `chart_deps/app/common/README.md`).
- CRDs live under `crds/<operator>/` as raw yaml plus an `update.sh` fetch script;
  update via the script, don't hand-edit.

## When creating/modifying a chart, checklist
1. Decide: highlevel chart (`charts/<name>`) vs dependency (`charts/chart_deps/<domain>/<name>`).
2. Chart.yaml: `apiVersion: v2`, `version: 0.1.0`, deps use `file://../chart_deps/...`
   with `alias` + `condition: <alias>.enabled`.
3. Copy the standard `_helpers.tpl` boilerplate, renamed to `<chart>.*`.
4. Prefer composing `core`/`common` templates over new raw manifests; only write a
   bespoke template when no `core` partial fits.
5. Add `enabled` gating + sensible defaults in `values.yaml`; mark
   environment-specific fields with `# SET THIS:`.
6. If it needs monitoring/logging, wire optional `podMonitor`/`servicemonitor` +
   `prometheus-rules` + `fluentbit` deps like `postgres-cluster` does.
7. Register it in `charts/environment/values.yaml` (`chart_apps`) if it should be
   deployable per environment.
8. Update `Chart.lock`/vendored `.tgz`s via `helm dependency update` and update
   root `CHANGELOG.md`.
