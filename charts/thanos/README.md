# Thanos

The stack renders Query, Query Frontend, Compactor, Store Gateway, and Ruler
through [`app/core`](../chart_deps/app/core). ServiceMonitors use
[`prometheus/lib`](../chart_deps/prometheus/lib). There are no service subcharts.

```yaml
common:
  thanos:
    logLevel: info
query:
  enabled: true
  thanos:
    stores:
    - prometheus-thanos:10901
  workload:
    resources:
      requests:
        cpu: 10m
        memory: 50Mi
compactor:
  enabled: true
storegateway:
  enabled: true
```

Each component is disabled by default. `<component>.enabled` gates all its
resources. Resource defaults live under `common.<resource>` and workload defaults
under `common.workload`; component settings override them.
Maps merge recursively, lists replace shared lists, and explicit false or zero
values are preserved. Each component gets an independent copy of the defaults.
Query, Query Frontend, and Compactor render Deployments; Store Gateway and Ruler
render StatefulSets. Workload kinds are fixed by their renderer loops;
`deploymentEnabled` and `statefulsetEnabled` are no longer used.
Each resource has a helper and a YAML renderer following the Service pattern.
ServiceMonitor selectors combine component selectors with `serviceMonitor.selectorLabels`.

Migration: move pod and workload settings (image, resources, args, ports,
environment, volumes, security, scheduling, and StatefulSet settings) into
`common.workload` and `<component>.workload`. Separate resource settings such as
`service`, `ingress`, `serviceAccount`, and `pvcs` remain siblings
of `workload`. Thanos application settings remain under `common.thanos` and
`<component>.thanos`. Shared defaults formerly in `chart_deps/thanos/service`
now live in this chart.
Update overrides and templated references from `common.fullname` to
`thanos.stackFullName`, and from `thanos-service.prefix` to
`thanos.fullname`. Names and selectors are preserved; chart metadata labels
now identify the Thanos chart. Rebuild dependencies with `helm dependency build .`.

Workload settings include `<component>.workload.image`, `resources`, `ports`,
`args`, `command`, volumes, and pod security. Argument defines and templated
resource fields use the original chart values: for example,
`.Values.query.thanos.stores` and `.Values.compactor.workload.resources`.
Shared defaults remain at `.Values.common.*`, and globals at `.Values.global.*`.
Resource helpers merge defaults into resource objects without replacing `.Values`.

All workload containers, including init containers and sidecars, receive environment
variables only from `common.workload.environment` followed by
`<component>.workload.environment`.
These lists are concatenated independently of the normal values merge.

Query and Store Gateway ingresses use `query.ingress` and `storegateway.ingress`.
Both the component and its ingress must be enabled. Extra stack ingresses use
`additional_ingress`. Kong plugins and the shared object-store Secret remain at
the stack level. The Secret requires `global.company.name`,
`global.env.short_name`, and `global.env.cloud.buckets.type`. Compactor and Store
Gateway use the external service account named `thanos`; consumers must provide
it and its object-store permissions.

HTTP listeners use container port 10902; Services expose port 9090 and target the
named `http` container port. Query Frontend sends downstream requests to the Query
Service on 9090. gRPC listeners use 10901. Custom listeners require matching
`workload.args`, `workload.ports`, Service ports, and NetworkPolicy rules.

Compactor storage uses `compactor.pvcs.data.storage`; StatefulSet storage uses
`<component>.workload.volumeClaimTemplates.data.storage`. PVC volumes and mount
paths belong to `workload.volumes` and `workload.volumeMounts`; the standalone PVC
map only configures the claim resource. Compactor's `thanos.dataDir` and
Ruler's `thanos.dataPath` also set data mount paths. Ruler requires an externally
provided rules ConfigMap (by default `<stack-fullname>-ruler`) and a nonempty
`ruler.thanos.alertmanagers` URL list. Its templated `queryURL` defaults to
`https://tq.<global.env.dns.domain>` for alert links to the Query UI.

The five argument defines adapt Bitnami Thanos chart 17.3.1. Override a component's
`workload.args` with a list or templated YAML list to replace generated arguments;
`workload.command` is a normal workload override. `thanos.extraFlags` supports templated
lists. Query accepts explicit endpoints through `query.thanos.stores`.
Compactor's `thanos.cronJob.enabled` controls `--wait` only; it does not change the
workload kind. Custom TLS, HTTP, cache, or discovery configuration requires
explicit arguments and matching resource mounts.

The legacy `minio`, `volumePermissions`, stack `networkPolicy`, and
`receiveDistributor` interfaces remain omitted. Receive is not rendered.
HPAs and ConfigMaps are not rendered; Deployments use `workload.replicaCount`.
Per-component policies use `<component>.networkPolicy`. Store Gateway retains
its existing headless Service reference; that headless Service is not generated
by this stack. Ruler uses its primary Service as its governing Service and has an
8 GiB data claim by default; its configuration does not require per-pod DNS.

Run render regressions with `python3 tests/test_args.py` (requires Helm and PyYAML).
