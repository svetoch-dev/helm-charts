# Thanos

The stack declares six direct dependencies on
[`thanos/service`](../chart_deps/thanos/service): `query`, `queryFrontend`,
`compactor`, `storegateway`, `ruler`, and `recieve`. Each wrapper uses
[`app/common`](../chart_deps/app/common) under its original dependency name `common` for Helm 3 compatibility.

```yaml
query:
  enabled: true
  common:
    thanos:
      logLevel: info
      stores:
        - prometheus-thanos:10901
    resources:
      requests:
        cpu: 10m
        memory: 50Mi
compactor:
  enabled: true
storegateway:
  enabled: true
```

Each component is disabled by default. `<component>.enabled` gates its dependency.
Native common/core resource settings live under `<component>.common`, including
`image`, `resources`, `ports`, `args`, `command`, storage, security, and monitoring.
Thanos CLI and application settings live under `<component>.common.thanos`.
The `recieve` alias retains its existing spelling; its workload and command use
`receive`. There is no separate stack-level `thanos.enabled` switch.

Build dependencies from this chart directory, from the inner chart outward:

```sh
helm dependency build ../chart_deps/thanos/service
helm dependency build .
```

Migration from the previous flat `common` layout:

- Keep native resource settings at `<component>.common.*`.
- Move Thanos settings such as `logLevel`, `logFormat`, `extraFlags`, `stores`,
  `containerPorts`, retention, configuration, and discovery inputs beneath
  `<component>.common.thanos`.
- Custom arguments remain `query.common.args`, not `query.common.thanos.args`.
- Common's Kubernetes Service interface stays at `<component>.common.service`,
  including its ports list and annotations. The Thanos argument option
  `additionalHeadless` belongs to `<component>.common.thanos.service`.
- Update templated CLI references to `.Values.thanos.*`. Resource references such
  as `.Values.service.ports` and `.Values.resources` remain unchanged.
- Keep the enablement paths `<component>.enabled` unchanged.

The original `common` dependency name is intentional: Helm 3.22 mishandles a
renamed nested dependency when its wrapper is included repeatedly under aliases.
Using `common.thanos` avoids that nested alias and supports the Helm 3 renderer.

Stack ingresses, Kong plugins, and the shared object-store Secret stay at the
stack level. The Secret requires `global.company.name`, `global.env.short_name`,
and `global.env.cloud.buckets.type`. Compactor and storegateway use the external
service account named `thanos`; consumers must provide it and its object-store
permissions.

Compactor storage uses `compactor.common.pvcs.data.storage`; StatefulSet storage
uses `<component>.common.volumeClaimTemplates.data.storage`. Ruler requires
`ruler.common.thanos.config` (a YAML rules string) and either
`ruler.common.thanos.alertmanagers` or `ruler.common.thanos.alertmanagersConfig`.
Receive renders its ConfigMap from `recieve.common.thanos.hashrings`; configure
its ring and args before scaling past its default single-replica local endpoint.

The six defines in `templates/args/` follow Bitnami Thanos chart 17.3.1. Each
component's `common.args` calls its matching define. Override that field with a
list or a templated YAML list to replace generated arguments; `common.command`
remains a normal resource override. The reusable service chart has no CLI defaults.

Inside each define, `.Values.thanos` is the local component's application config.
Inputs such as `query.common.thanos.storegateway` and
`ruler.common.thanos.query` describe discovery targets explicitly; they do not
read sibling dependency values automatically. No parent-values adapter is used.

For configurable listeners, `thanos.containerPorts` also supplies pod port numbers.
Query keeps the upstream fixed HTTP/gRPC listeners; override its args and ports
together when changing them. Compactor `thanos.dataDir`, ruler `thanos.dataPath`,
and receive `thanos.tsdbPath` also supply their data mount paths. Receive retention
uses `thanos.tsdbRetention`, and its replication protocol uses
`thanos.replicationProtocol`.

Optional HTTP/TLS, cache, discovery, alertmanager, sharding, and CronJob options
select upstream argument branches. Configure their matching Secrets, ConfigMaps,
mounts, Services, and workload kinds through resource values. These arguments do
not create those resources or turn a Deployment into a CronJob.

The legacy `minio`, `volumePermissions`, stack `networkPolicy`, and
`receiveDistributor` interfaces remain omitted. Per-component policies use
`<component>.common.networkPolicy`. Deployment components support common autoscaling.

Resource names, selectors, claims, and service ports retain their identities.
Chart labels reflect the `common` dependency. The existing StatefulSet
headless Service references are retained; the prior unsharded configuration did
not render corresponding headless Services for storegateway, ruler, or receive.

The upstream source and license are recorded in `licenses/`. Run the focused
render regressions with `python3 tests/test_args.py` (requires Helm and PyYAML).
