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

Start here even from a nested directory. Resolve the relevant dependency refs, then load only the module instructions for the task. Follow the map and read applicable `AGENTS.md` files from parent to child. For a change across modules, read each affected scope.

| Task | Context to load |
|---|---|
| Change a Helm chart or stack, including the Argo CD controller in `charts/argocd/` | [Chart rules](charts/AGENTS.md) |
| Change the root Application or how the consumer's `envs.yaml` selects environments | [`environments`](charts/environments/AGENTS.md) |
| Change an environment's child Applications, values, or CRD routing in `env.yaml` | [`environment`](charts/environment/AGENTS.md) |
| Change workload composition in `common` or reusable helpers in `core` | [Workloads and helpers](charts/chart_deps/app/AGENTS.md) |
| Update a vendored upstream CRD | [CRD sources](crds/AGENTS.md) |

## Local rules

- Record meaningful chart changes in [`CHANGELOG.md`](CHANGELOG.md) and dependency version changes as `<from_version> -> <to_version>`. See [`UPGRADING.md`](UPGRADING.md) for consumer migrations.

## Checks

- Run `pre-commit run --files <changed-files>` after installing the [repository hooks](README.md#prerequisites). The YAML hook excludes Helm YAML templates and vendored CRDs. Check rendered manifests separately.
- For chart changes, run `helm lint <chart> -f <fixture>` and `helm template <release> <chart> -n <namespace> -f <fixture>` with neutral inputs. Add `-f charts/globals.yaml` before the fixture where the chart uses shared globals. Use the checks in the affected module instructions to choose inputs and verify output.
