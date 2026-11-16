# helm-charts

## Shared Rod context

Before repository work, read the shared [AGENTS.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/AGENTS.md), [map.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/map.md), and [repositories.md](https://github.com/svetoch-dev/rod-docs/blob/docs/rep-7-context-map/docs/ai/repositories.md) on the temporary `rod-docs` branch `docs/rep-7-context-map`. Use a local copy only after verifying the linked ref. Report inaccessible required instructions and pause work that depends on them. Look for applicable shared skills at the same ref.

## Purpose

Argo CD App-of-Apps is the main integration path. It assembles shared charts, product charts, and manifests into Kubernetes environments. Service charts can also be used separately with their values, dependencies, and any required CRDs. Environment configuration stays in the consuming repository.

## Repository map

```text
rod / consuming repository
└─ helm-charts [you are here] — shared Kubernetes charts and Argo CD App-of-Apps templates
```

- **Choose environments:** Start at the consumer's `envs.yaml` and `repository.paths`. [`charts/environments/`](charts/environments/) renders one Application per enabled `global.envs` entry and can render the `root` Application that points back to this chart. It can also import globals from configured Terraform JSON.
- **Change one environment:** Its Application selects [`charts/environment/`](charts/environment/) and passes `environments/<cloud_short_name>/env.yaml` from the consumer. The chart overlays `chart_apps` on defaults generated from `envApps`, renders enabled chart Applications, and can render separate CRD and manifest Applications. Follow the actual chart source and Helm values, normally `environments/<cloud_short_name>/<app>/values.yaml`. See [generated application defaults](README.md#generated-application-defaults).
- **Change Argo CD itself:** [`charts/argocd/`](charts/argocd/) packages the controller and supporting components. The `root` Application is defined in [`charts/environments/templates/root.yaml`](charts/environments/templates/root.yaml).
- **Change one chart or stack:** Start with its `charts/<name>/Chart.yaml`, `values.yaml`, and templates. Use [`app/common`](charts/chart_deps/app/common/) for a typical workload and [`app/core`](charts/chart_deps/app/core/), a library chart, for individual resource helpers. Use [`postgres`](charts/postgres/) or [`redis`](charts/redis/) for separately selected operator and resource components, and [`gha-runner`](charts/gha-runner/) or [`vedro`](charts/vedro/) for pinned upstream composition.
- **Find shared inputs:** [`charts/globals.yaml`](charts/globals.yaml) defines shared values. [`charts/chart_deps/`](charts/chart_deps/) contains local dependencies, including the [Prometheus](charts/chart_deps/prometheus/lib/) and [Fluent Bit](charts/chart_deps/fluent/fluentbit/lib/) libraries. [`crds/`](crds/) holds versioned CRDs and update scripts.

## Local rules

- Preserve values keys, resource names, labels, and selectors. Where absence differs from explicit `false`, zero, or empty values, check key presence and verify both cases. Keep templated fields on their supported `tpl` context, copy shared maps before mutation, and namespace helpers. Do not use `dig`. Follow each chart's ingress interface (`ingress` in `common`, `ingresses` where a stack uses it).
- Pin versions in first-party dependency declarations and match optional dependency conditions to a Boolean values key under the alias or dependency name. Follow actual `file://` paths through consumers and rebuild changed tracked packages from the inner dependency outward. Use `helm dependency build` for an existing lock and `helm dependency update` when intentionally changing resolution. Check locks, `.gitignore`, and tracked archives with `git ls-files`. Leave ignored packages out. See [dependency rebuilds](UPGRADING.md#5-rebuild-local-dependencies).
- Resolve each generated Application's source, target revision, and values paths. `chart_apps.<app>.enabled` controls inclusion. `app: true` selects default product chart and values paths, which explicit `chart` and `helm` settings can override. Default new shared stack registrations to disabled unless the task changes that contract. Preserve finalizers and pruning settings for unrelated changes. Check the removal impact before disabling or renaming an Application.
- Keep shared operator installation and resource declarations separately selectable. Chart Applications emit `helm.skipCrds: true`. `crds.enabled` enables the separate CRD Application and `crds.operators.<operator>.enabled` selects its sources. Use pinned upstream sources and the affected `crds/<operator>/update.sh`. Hand patches require explicit agreement, documented provenance, and reproducible verification. Check cluster-scoped names and ownership across namespaces. Establish CRDs before custom resources and keep the controller and its credentials available through cleanup.
- Record meaningful chart changes in [`CHANGELOG.md`](CHANGELOG.md) and spell out dependency version changes as `<from_version> -> <to_version>`. See [`UPGRADING.md`](UPGRADING.md) for consumer migrations.

## Checks

- Run `pre-commit run --files <changed-files>` after installing the [repository hooks](README.md#prerequisites). The YAML hook excludes Helm YAML templates and vendored CRDs. Check rendered manifests separately.
- For a changed chart, prepare a neutral values fixture from its README, defaults, or consumer input schema. Add `-f charts/globals.yaml` before the fixture where the chart uses shared globals. Run `helm lint <chart> -f <fixture>` and `helm template <release> <chart> -n <namespace> -f <fixture>`. Check expected resources, identities, duplicate keys, and enablement. Render representative consumers of changed libraries and tracked packages.
- For App-of-Apps changes, render `environments` and then `environment` with the corresponding inputs. The plural chart expects `tfvars` JSON by default. Supply synthetic JSON with `--set-file tfvars=<fixture.json>` when testing the import, or set `root.globalFromTfVars=false` for a YAML-only fixture. Verify rendered names, chart and values paths, target revisions, and enabled and disabled entries at both levels. See [upgrade checks](UPGRADING.md#6-validate-before-syncing).
