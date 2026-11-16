# Workload chart and resource helpers

- [`core`](core/) is a library of resource helpers. Preserve the existing `core.*` include contracts and render through representative consuming charts. Follow the parent chart rules for refreshing affected tracked packages.
- [`common`](common/) is the application chart for generic workloads and uses `core` helpers. Keep its singular `ingress` values interface. Read its [`values.yaml`](common/values.yaml), templates and [README](common/README.md) before changing its inputs or defaults.
