# Environment selection and root Application

- Start at the consumer's `envs.yaml` and `repository.paths`. [`root.yaml`](templates/root.yaml) renders the optional root Application, which points back to this chart. [`envs.yaml`](templates/envs.yaml) renders an Application per enabled `global.envs` entry. It selects the [singular chart](../environment/AGENTS.md) and passes environment globals, `envApps` when set, and the path to `environments/<cloud_short_name>/env.yaml`.
- Verify which environments are emitted and their names, sources, revisions, and values paths. For handoff changes, render both charts and inspect the child Applications.
- `root.globalFromTfVars` defaults to `true`. Use `--set-file tfvars=<fixture.json>` with synthetic JSON when testing that import. Set `root.globalFromTfVars=false` for YAML-only fixtures. See [upgrade checks](../../UPGRADING.md#6-validate-before-syncing).
