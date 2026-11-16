# Vendored CRD sources

- Update the affected operator with its `update.sh` and a pinned upstream version. Inspect the script's working directory and file replacements first. Hand patches require explicit agreement, documented provenance, and reproducible verification.
- Review changed manifests for schema changes, cluster-scoped names and ownership across namespaces. Establish CRDs before custom resources and keep the controller and its credentials available through cleanup. For how the CRD Application selects sources, read [environment rules](../charts/environment/AGENTS.md).
