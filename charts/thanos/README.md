# Thanos

The stack uses six instances of [`app/common`](../chart_deps/app/common), grouped
under `thanos` so existing service enablement and query store paths still work:

```yaml
thanos:
  enabled: true
  query:
    enabled: true
    stores:
      - prometheus-thanos:10901
  compactor:
    enabled: true
  storegateway:
    enabled: true
```

Build local dependencies from the chart directory, from the inner chart outward:

```sh
helm dependency build services
helm dependency build .
```

Services are `query`, `queryFrontend`, `compactor`, `storegateway`, `ruler`, and
`recieve`. The `recieve` values key retains the wrapper's spelling; its workload
and Thanos command use `receive`. Each service is disabled by default.

Each service accepts the common chart's workload, service, service account,
storage, security, scheduling, and monitoring values. Deployment services also
support the common chart's autoscaling values. The grouping
chart keeps `thanos.enabled` as the master switch. Stack ingresses, Kong plugins,
and the shared object-store Secret remain configured at the stack level.

The object-store Secret requires `global.company.name`, `global.env.short_name`,
and `global.env.cloud.buckets.type`. Compactor and storegateway retain the existing
external service account named `thanos`; consumers must provision that account
and its object-store permissions.

Migration from the Bitnami dependency:

- Configure the image separately with `thanos.<service>.image.repository` (including
  the registry), `.tag`, and `.pullPolicy`, replacing `thanos.image`.
- Configure monitoring with `thanos.<service>.serviceMonitor`, replacing
  `thanos.metrics`. Existing ServiceMonitor names and selectors are retained.
- Configure compactor storage with `thanos.compactor.pvcs.data.storage`, replacing
  `thanos.compactor.persistence.size`. The existing PVC name is retained.
- Configure StatefulSet storage with
  `thanos.<service>.volumeClaimTemplates.data.storage`. Keep the existing `data`
  claim name and metadata when upgrading an existing StatefulSet.
- `args` accepts a list or a templated YAML list string. The default helper uses
  `logLevel`, `logFormat`, and `extraFlags`, plus query `stores`/`replicaLabel`,
  compactor retention settings, ruler `alertmanagers`, and receive retention and
  replication settings. Override `args` for other Thanos flags.
- Ruler requires `thanos.ruler.config` (a YAML rules string) and a nonempty
  `thanos.ruler.alertmanagers` URL list. It renders a rules ConfigMap.
- Receive renders a hashring ConfigMap from `thanos.recieve.hashrings`. Its default
  local endpoint and ring describe a single replica; configure both `args` and
  `hashrings` before using multiple replicas.
- The legacy `minio`, `volumePermissions`, stack `networkPolicy`, and
  `receiveDistributor` interfaces are omitted. Per-service generic NetworkPolicy
  resources preserve the existing policies and can be configured under each
  service's `networkPolicy` values.

Workload names, selectors, data claims, and service ports retain the previous
identities. Chart/version labels reflect the common dependency. This migration
retains the old StatefulSet governing service names; the upstream configuration
did not render the corresponding headless Services for the default unsharded
storegateway, ruler, or receive workloads.
