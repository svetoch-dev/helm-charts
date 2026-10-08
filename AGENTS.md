# Repository Guidelines

## Purpose and architecture

- This is a public Helm repository for reusable infrastructure stacks and application dependencies.
- It supports the rod GitOps approach: shared charts, environment configuration in a consuming repository, and Argo CD App-of-Apps.
- Compose existing charts and operator resources; keep environment-specific configuration outside reusable templates.
- Do not introduce real company names, cloud IDs, credentials, or consumer-specific paths into reusable defaults or examples.

## Repository structure

- `charts/<name>/`: deployable service or stack charts, such as `postgres`, `redis`, `prometheus`, and `vedro`.
- `charts/chart_deps/<domain>/<name>/`: reusable building blocks grouped by domain.
  - `app/core`: library chart with shared Kubernetes resource templates.
  - `app/common`: application chart composing `core` templates for generic workloads.
  - Other domains contain operator resources, monitoring, logging, and service-specific dependencies.
- `charts/environments/`: generates the root and per-environment Argo CD Applications; can read Terraform-generated globals.
- `charts/environment/`: generates chart Applications, a CRD Application, and an Application for raw manifests.
- `charts/globals.yaml`: shared global values skeleton and defaults.
- `crds/<operator>/`: upstream CRD manifests and an `update.sh` download script.
- `scripts/`: operational helpers; inspect their effects before running them.
- `CHANGELOG.md`: repository releases and changes grouped by affected chart.
- Environment overrides and application charts normally belong to the consuming repository, not this one.

## Task workflow

1. Read the relevant files and inspect the branch and working tree before proposing changes.
2. Present a short implementation plan: goal, affected paths, approach, checks, and material risks.
3. Obtain user agreement before implementation.
   - Read-only investigation may precede agreement.
   - Continue within an approved plan without repeatedly requesting permission.
   - Agree material scope changes before implementing them.
4. Make the smallest change that satisfies the task; preserve unrelated user edits.
5. Inspect the diff and run relevant checks before considering the work complete.
6. Report what changed, what was checked, and any unresolved limitations.

## Collaboration for complex decisions

- For architectural questions, difficult reasoning, or complex tasks, use exactly two assisting agents when available.
- Form a short, evidence-based discussion between three roles:
  - Lead agent: experienced DevOps engineer; owns architecture, GitOps behavior, and operational impact.
  - Programmer: `gpt-6-sol` with `medium` reasoning; checks interfaces, templates, and implementation simplicity.
  - Tester: `gpt-6-luna` with `high` reasoning; checks failure cases, compatibility, and meaningful verification.
- Give both agents the same question, relevant paths, constraints, and proposed approach.
- Ask each for a recommendation, supporting file references, and the main objection or risk.
- Share both reports and the lead's position for one short round of cross-review.
- The lead combines the evidence into a decision, checks disputed facts, and presents unresolved choices to the user.
- Default agent work to read-only; assign disjoint files explicitly if parallel editing is needed.
- Do not turn routine edits into a multi-agent process or treat majority agreement as proof.

## Chart design: KISS

- Find the closest existing chart before designing a new interface.
  - `charts/postgres` and `charts/redis`: operator and resource composition.
  - `charts/gha-runner` and `charts/vedro`: upstream dependencies with focused local configuration.
  - `charts/chart_deps/app/common`: generic workload composition.
- Prefer a small wrapper around a pinned upstream chart over copying its templates.
- Reuse `common` for ordinary workloads and `core` partials for individual Kubernetes resources.
- Write custom templates only where an existing dependency or partial does not cover the requirement.
- Do not add unused helpers, empty template files, duplicate switches, or speculative fallback logic.
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
- Do not run `helm install/upgrade/uninstall`, Kubernetes writes, Argo CD sync, or cloud-changing scripts without explicit authorization.
- If a required check is unavailable or fails, report it and resolve the issue before committing; do not bypass hooks silently.

## Git, commits, and pull requests

- Do not push without explicit user authorization; a requested local change or commit does not authorize a push.
- Before committing, inspect the complete staged diff and run the checks appropriate to its contents.
- Stage only task-related paths; do not include existing user changes or generated artifacts blindly.
- Do not amend, rebase, force-push, or discard user changes without authorization for that operation.
- New commit subjects use `<fix|add|remove> - <short description>`.
  - `fix - preserve explicit ingress settings`
  - `add - compose vedro resource chart`
  - `remove - duplicate dependency defaults`
- Keep commits focused; describe the result rather than the work process.
- For meaningful chart changes, update the appropriate release entry in `CHANGELOG.md`.
- Create a PR only when requested; use a concise title and this short description structure:
  - **Problem:** what was missing or incorrect; link an issue if one exists.
  - **Solution:** what changed and why.
  - **Affected modules:** charts, dependencies, CRDs, or App-of-Apps templates touched.
  - **Impact:** effects on consumers, defaults, resource identity, compatibility, and any migration needed.
  - **Checks:** commands run, results, and any remaining verification gap.
- Do not claim checks, compatibility, or deployment results that were not verified.
