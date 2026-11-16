# Repository Guidelines

## Shared Rod context

Before repository work, read the shared [AGENTS.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/AGENTS.md), [map.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/map.md), and [repositories.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/repositories.md) on `rod-docs` branch `docs/rep-7-context-map`. Use a local copy only after verifying that it matches the linked ref. Pause work that depends on any required file you cannot access. A separate update will replace these branch links with links to the shared context tag.

```text
rod / consuming repository
└─ helm-charts [you are here] — shared Kubernetes charts and Argo CD App-of-Apps templates
```

Find local task entry paths under [Repository structure](#repository-structure).

## Purpose and architecture

The main integration path is Argo CD App-of-Apps. It composes shared infrastructure charts, product charts, and manifests into Kubernetes environments. Service and stack charts can also be used separately with their values, dependencies, and any required CRDs. Keep environment configuration in the consuming repository.

## Repository structure

### Argo CD App-of-Apps

- Start in the consuming repository at `envs.yaml`. Follow `repository.paths` to the configured chart locations. When enabled, the plural chart also reads its configured Terraform JSON as a source of globals.
- [`charts/environments/`](charts/environments/) (plural) renders the optional `root` Application, which points back to this chart, and one Application per enabled entry in `global.envs`. Each environment Application selects the singular chart and passes its `environments/<cloud_short_name>/env.yaml` and environment globals.
- [`charts/environment/`](charts/environment/) (singular) composes **one** environment. It generates defaults from `envApps`, overlays explicit `chart_apps`, and renders Applications for enabled entries. It can also render separate Applications for CRDs and raw manifests. Follow each Application's configured chart source and Helm values. By default, per-chart overrides come from `environments/<cloud_short_name>/<app>/values.yaml` in the consumer.
- [`charts/argocd/`](charts/argocd/) packages Argo CD itself and supporting components. An environment can select it as one of its chart Applications.

### Service charts and shared components

- `charts/<name>/`: reusable service and stack charts, such as `postgres`, `redis`, `prometheus`, and `vedro`. For a single chart, start with its `Chart.yaml` and `values.yaml`.
- `charts/chart_deps/<domain>/<name>/`: reusable dependencies. `app/core` is a library chart for Kubernetes resources. `app/common` is an application chart for generic workloads built with `core`.
- `charts/globals.yaml`: shared global values skeleton and defaults.
- `crds/<operator>/`: upstream CRD manifests and an `update.sh` download script.
- `scripts/`: operational helpers.
- `CHANGELOG.md`: repository releases and changes grouped by affected chart.

## Helm specialist review

For architectural questions, difficult reasoning, or complex Helm tasks, use two complementary specialists when available and authorized under the shared workflow and within the session's reasoning limits. The lead owns the architecture, GitOps behavior, and operational impact. Include the lead's position in the shared cross-review.

Choose reasoning effort by complexity independently of reviewer specialty. Use low or medium for straightforward tasks, high for interacting components or failure analysis, and extra high for conflicting evidence or complex tradeoffs. Prefer repository checks over additional model reviews.

## Chart design

- Find the closest existing chart before designing a new interface.
  - `charts/postgres` and `charts/redis`: operator and resource composition.
  - `charts/gha-runner` and `charts/vedro`: upstream dependencies with focused local configuration.
  - `charts/chart_deps/app/common`: generic workload composition.
- Prefer a small wrapper around a pinned upstream chart over copying its templates.
- Reuse `common` for ordinary workloads and `core` partials for individual Kubernetes resources.
- Check other domain libraries before writing custom templates, including `charts/chart_deps/prometheus/lib` and `charts/chart_deps/fluent/fluentbit/lib`; reuse partials whose interfaces fit the requirement.
- Write custom templates only where an existing dependency or partial does not cover the requirement.
- Do not add empty template files or duplicate values switches.
- Do not duplicate upstream defaults unless the wrapper intentionally changes behavior; explain necessary overrides.
- Add local abstractions only when they remove concrete duplication and keep the values interface understandable.
- Separate controller installation from resource declarations when applications share an operator.
- Add monitoring and logging only when applicable; follow the nearest chart's optional dependency pattern.

## Dependencies and chart files

- Use `apiVersion: v2` and `Chart.yaml`; add `values.yaml` for configurable defaults and templates when the chart owns rendered resources.
- Keep library charts as `type: library`; do not give them deployment switches merely for uniformity.
- Local dependencies use paths relative to `Chart.yaml`, for example `file://../chart_deps/app/common`.
- Pin external chart versions and preserve the existing versioning convention; do not bump unrelated charts.
- Gate optional deployable dependencies with `condition: <values-key>.enabled`.
- Match the values key to the dependency alias, or its name when there is no alias.
- Use descriptive aliases when needed, such as `postgres-main`; do not invent another naming layer.
- Keep `Chart.lock` consistent with dependency declarations.
- Dependency archives live in the consuming chart's `charts/` directory.
  - Most such directories are ignored; `.gitignore` allows selected dependency-chart archives to be tracked.
  - Check `.gitignore` and `git ls-files` before staging generated archives; do not force-add ignored packages.
- After changing a local dependency, refresh affected consumers from the inner dependency outward.
  - Helm dependency updates are not recursive.
  - Rebuild tracked archives, including `app/common/charts/core-*.tgz` when changing `core`.
  - Use `helm dependency build <chart-path>` to rebuild dependencies from an existing lock; use `helm dependency update <chart-path>` when intentionally refreshing the lock.

## Values and template conventions

- YAML uses two-space indentation; follow adjacent files for sequence indentation and template layout.
- Preserve existing values keys, resource names, labels, and selectors unless the task explicitly changes the interface.
- Keep optional stack components disabled by default where the existing interface follows that pattern.
- Helm treats missing, `false`, empty, and zero values differently: preserve explicit choices when implementing defaults.
- Read shared environment data from `.Values.global.*`; introduce per-chart overrides only for a concrete need.
- `global` data is combined from shared defaults and consuming environment configuration; the App-of-Apps charts propagate it.
- Use `tpl` only for fields whose interface supports templated strings; pass the appropriate root context.
- Use `deepCopy` before mutating shared maps; avoid cross-application effects while merging values.
- Reuse labels and naming helpers; namespace helper names to avoid collisions.
- For stack ingress resources, follow `ingresses:` and `core.ingress` where that interface is already used.
  - `common` has its own `ingress` interface; do not rename it for stylistic consistency.
- Document required values, meaningful overrides, and upstream links concisely; comments should explain reasons or constraints.

## App-of-Apps and CRDs

- `environment` merges generated application defaults with explicit `chart_apps` entries; explicit entries override generated ones.
- Register a new environment-deployable stack in `charts/environment/values.yaml`, normally disabled initially.
- `chart_apps.<name>.app` selects the consuming repository's application-chart path; it does not enable the application.
- Paths come from `repository.paths`; inspect these settings instead of assuming charts or overrides live locally.
- Check each generated `targetRevision`; changing the parent Application's revision alone does not guarantee matching child revisions.
- Chart Applications set `helm.skipCrds: true`; CRD sources are selected through `crds.enabled` and `crds.operators.<operator>.enabled`.
- Update upstream CRDs through their download script with a pinned version; review the resulting diff.
- Respect each CRD's scope: cluster-scoped names must be unique across namespaces.
- Plan operator lifecycle ordering: install CRDs before custom resources and keep the controller and credentials until cleanup finishes.

## Restrictions

- Do not use `dig` in Helm templates.
- Do not hand-edit downloaded upstream CRD manifests in `crds/`; update them through the pinned source and download script.
  - Any necessary local patch requires explicit agreement, documented provenance and reason, and a reproducible update process with verification.
- Do not remove finalizers or enable destructive pruning as part of an unrelated chart change.

## Verification and pre-commit

- Install repository hooks after cloning: `pre-commit install`.
- Run `pre-commit run --files <changed-files>` before a commit; use `--all-files` for intentionally broad checks.
- The configured hook runs strict-mode yamllint with relaxed rules and two-space indentation.
  - CRD YAML and Helm YAML templates are excluded, so the hook does not validate rendered manifests.
- For chart changes, run local checks with representative values:
  - `helm lint <chart-path> -f charts/globals.yaml -f /tmp/example-values.yaml`
  - `helm template example <chart-path> --namespace example -f charts/globals.yaml -f /tmp/example-values.yaml > /tmp/rendered.yaml`
- Supply neutral fixture values for required globals; empty defaults are not necessarily a working environment.
- Check changed behavior enabled and disabled, required resource fields, names, namespaces, references, and unexpected resources.
- For `core`, `common`, or App-of-Apps changes, check representative affected consumers and generated Applications.
- A successful lint or template run does not prove deployment or cloud reconciliation works.
- No dedicated test suite is currently tracked; add focused regression checks only when they address a concrete risk.
- If a required check is unavailable or fails, report it and resolve the issue before committing; do not bypass hooks silently.

## Git, commits, and pull requests

- New commit subjects use `<fix|add|remove> - <short description>`.
  - `fix - preserve explicit ingress settings`
  - `add - compose vedro resource chart`
  - `remove - duplicate dependency defaults`
- Describe the result in the commit subject.
- For meaningful chart changes, update the appropriate release entry in `CHANGELOG.md`.
- Whenever updating a dependency, explicitly state its version change in `CHANGELOG.md` using `<from_version> -> <to_version>`, for example `v3.5.1 -> v3.6.1`.
- For an authorized PR, use a concise title and link the issue if one exists. Name the affected charts, dependencies, CRDs, or App-of-Apps templates. Explain the impact on consumers, defaults, resource identity, and compatibility, along with any necessary migration and gaps in compatibility or deployment verification.
