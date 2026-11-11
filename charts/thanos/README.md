# Thanos

The stack declares six direct dependencies on
[`thanos/service`](../chart_deps/thanos/service), aliased as `query`,
`queryFrontend`, `compactor`, `storegateway`, `ruler`, and `recieve`.
Each wrapper uses [`app/common`](../chart_deps/app/common) and supplies shared
Thanos defaults. This stack sets only service-specific overrides.

```yaml
query:
  enabled: true
  common:
    stores:
      - prometheus-thanos:10901
compactor:
  enabled: true
storegateway:
  enabled: true
```

Each service is disabled by default. `<service>.enabled` gates the entire service
dependency; `<service>.common.*` configures its workload. There is no separate
`thanos.enabled` master switch. The `recieve` alias retains the wrapper's spelling;
its workload and Thanos command use `receive`.

Build dependencies from the chart directory, from the inner chart outward:

```sh
helm dependency build ../chart_deps/thanos/service
helm dependency build .
```

Migration from the previous grouping chart:

- Move `thanos.<service>.enabled` to `<service>.enabled`.
- Move other `thanos.<service>.*` settings to `<service>.common.*`, for example
  `thanos.query.stores` becomes `query.common.stores`.
- Remove `thanos.enabled`. If it was false, keep every service disabled.
- Shared defaults now live in the reusable service chart; override them through
  `<service>.common.image`, `.serviceMonitor`, `.securityContext`, and other
  common chart values.

Stack ingresses, Kong plugins, and the shared object-store Secret remain at the
stack level. The Secret requires `global.company.name`, `global.env.short_name`,
and `global.env.cloud.buckets.type`. Compactor and storegateway retain the external
service account named `thanos`; consumers must provide it and its object-store
permissions.

Compactor storage is configured with `compactor.common.pvcs.data.storage`.
StatefulSet storage uses `<service>.common.volumeClaimTemplates.data.storage`.
Ruler requires `ruler.common.config` (a YAML rules string) and a nonempty
`ruler.common.alertmanagers` URL list. Receive renders its ConfigMap from
`recieve.common.hashrings`; configure both `args` and `hashrings` before scaling
past its default single-replica local endpoint.

The legacy `minio`, `volumePermissions`, stack `networkPolicy`, and
`receiveDistributor` interfaces remain omitted. Generic per-service policies use
`<service>.common.networkPolicy`. Deployment services support common autoscaling.

Resource names, selectors, data claims, and service ports retain their identities.
Chart labels reflect the common dependency. The existing StatefulSet governing
service names are retained; the prior configuration did not render corresponding
headless Services for the default unsharded storegateway, ruler, or receive.
