# Thanos Chart

Creates Query, Query Frontend, Compactor, Store Gateway, and Ruler workloads with
Services, storage, access policies, monitoring, and optional ingress resources.
Kubernetes resources use [`app/core`](../chart_deps/app/core); ServiceMonitors use
[`prometheus/lib`](../chart_deps/prometheus/lib).

## Usage

```yaml
global:
  company:
    name: example
  env:
    short_name: test
    cloud:
      buckets:
        type: gcs

common:
  thanos:
    logLevel: info
  workload:
    environment:
    - name: TZ
      value: UTC

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

queryFrontend:
  enabled: true
```

Set `query.thanos.stores` to existing Thanos StoreAPI endpoints. Save the example as
`values-example.yaml`, then build dependencies and render from this chart directory:

```sh
helm dependency build .
helm template example . --namespace monitoring -f values-example.yaml
```

## Requirements

| Name | Requirement |
|------|-------------|
| Helm | Helm 3 or Helm 4 with the local dependencies in `Chart.yaml` built. |
| Prometheus Operator | The `ServiceMonitor` CRD is required by default; disable `common.serviceMonitor.enabled` if it is unavailable. |
| Object storage | An existing bucket and access credentials for components that use object storage. |
| ServiceAccount | Compactor and Store Gateway default to an existing account named `thanos`; configure its object-store permissions. |
| Persistent storage | Storage provisioning for Compactor PVCs and Store Gateway/Ruler StatefulSet claims. |
| Ruler rules | An externally supplied rules ConfigMap when Ruler is enabled. |
| Ingress controllers | Controllers matching enabled ingress classes; TLS issuers or Secrets for their TLS configuration. |
| Kong | Kong CRDs and controller when `kong-plugins.enabled` is enabled. |

The chart does not create object-storage buckets, cloud permissions, or the
external `thanos` ServiceAccount.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `common` | Shared workload, resource, and Thanos defaults. | `object` | See `values.yaml` | no |
| `query` | Query workload and related resource settings. | `object` | `enabled: false` with component defaults | no |
| `queryFrontend` | Query Frontend workload and related resource settings. | `object` | `enabled: false` with component defaults | no |
| `compactor` | Compactor workload and related resource settings. | `object` | `enabled: false` with component defaults | no |
| `storegateway` | Store Gateway workload and related resource settings. | `object` | `enabled: false` with component defaults | no |
| `ruler` | Ruler workload and related resource settings. | `object` | `enabled: false` with component defaults | no |
| `global` | Shared environment information used by templated values. | `object` | Unset | for the default object-store Secret |
| `additional_ingress` | Additional stack ingress resources, keyed by entry name. | `map(object)` | `{}` | no |
| `secrets` | Stack Secret resources, keyed by entry name. | `map(object)` | Shared `thanos` object-store configuration | no |
| `kong-plugins.enabled` | Enable the Kong plugin dependency. | `bool` | `false` | no |
| `nameOverride` | Override the chart name used in naming and labels. | `string` | Chart name | no |
| `fullnameOverride` | Override the stack name prefix. | `string` | Derived from release and chart names | no |
| `namespaceOverride` | Override the namespace for chart resources. | `string` | Release namespace | no |

## Notes

- Each component's `enabled` flag gates its workload and related resources.
- Component settings override the matching `common` settings. Maps merge recursively; lists replace shared lists, except environment lists, which are concatenated.
- Environment variables come only from `common.workload.environment` followed by `<component>.workload.environment`. Main containers, init containers, and sidecars receive the combined list.
- HTTP listeners use container port `10902`; Services expose port `9090` and target the named `http` container port. gRPC listeners use `10901`.
- ServiceMonitor selectors combine component selectors with `serviceMonitor.selectorLabels`.

## Type Details

### `global`

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `company.name` | `string` | for the default Secret | Company prefix in the object-store bucket name. |
| `env.short_name` | `string` | for the default Secret | Environment suffix in the object-store bucket name. |
| `env.cloud.buckets.type` | `string` | for the default Secret | Object-store type, converted to uppercase in `objstore.yml`. |
| `env.dns.domain` | `string` | for ingress or the default Ruler query URL | Domain used by ingress hosts and alert links. |
| `ingress.class` | `string` | for the default Query ingress | Query ingress controller class. |
| `pomerium.policy.default` | YAML `string` | for the default Query ingress | Templated policy annotation. |
| `env.cloud.network.int_nat_gw` | `string` | for the default Kong plugin | Address permitted by the Store Gateway IP restriction plugin. |
| `env.type` | `string` | for default Query discovery | The default stores template generates endpoints for `internal`. |
| `env.cloud_short_name` | `string` | for default internal Query discovery | Name segment used in generated StoreAPI endpoints. |
| `externalEnvs` | `any` | no | A nonempty value adds the external Query endpoint to default internal discovery. |

The default bucket name is `<company.name>-thanos-<env.short_name>`. The shared
Secret is named `<stack-fullname>-thanos` and contains `objstore.yml`.

### `<component>`

`<component>` is `query`, `queryFrontend`, `compactor`, `storegateway`, or `ruler`.

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `enabled` | `bool` | no | Enable the component; defaults to `false`. |
| `workload` | `object` | no | Pod and Deployment/StatefulSet settings; overrides `common.workload`. |
| `thanos` | `object` | no | CLI settings; overrides `common.thanos`. |
| `service` | `object` | no | Primary Service settings; overrides `common.service`. |
| `additionalServices` | `list(object)` | no | Extra Services; Query defaults to an additional gRPC Service. |
| `serviceAccount` | `object` | no | Account creation and name; overrides `common.serviceAccount`. |
| `ingress` | `object` | no | Query or Store Gateway ingress settings; overrides `common.ingress`. |
| `networkPolicy` | `object` | no | Pod traffic policy; enabled by default through `common.networkPolicy`. |
| `podDisruptionBudget` | `object` | no | Disruption budget; enabled by default for Query, Query Frontend, Store Gateway, and Ruler. |
| `serviceMonitor` | `object` | no | Prometheus metrics discovery; enabled by default through `common.serviceMonitor`. |
| `pvcs` | `map(object)` | no | Standalone PVC declarations; Compactor defaults to a 15 GiB data claim. |
| `secrets` | `map(object)` | no | Component Secret declarations; merged with `common.secrets`. |

Query and Store Gateway ingresses are disabled by default. Their default hosts are
`tq.<global.env.dns.domain>` and `thanos-store.<global.env.dns.domain>` respectively.
Their backend Service ports are `9090` and `10901`.

### `common.workload` and `<component>.workload`

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `replicaCount` | `integer` | no | Workload replicas; shared default is `1`. |
| `containerName` | `string` | no | Component container name; defaults are set per component, including `query-frontend`. Also determines the component name suffix and label. |
| `image` | `object` | no | Repository, tag, and pull policy; shared defaults are `quay.io/thanos/thanos`, `v0.41.0`, and `IfNotPresent`. |
| `resources` | `object` | no | Container resource requests and limits; component defaults are in `values.yaml`. |
| `ports` | `list(object)` or YAML `string` | no | Container ports; defaults are HTTP `10902` and gRPC `10901`, with component overrides. |
| `args` | `list(string)` or YAML `string` | no | Replace the component's generated argument list. Strings support Helm templating. |
| `command` | `list(string)` | no | Override the container command. |
| `environment` | `list(object)` | no | Kubernetes environment entries, including `valueFrom`; concatenated with shared entries. |
| `volumes` | `list(object)` | no | Pod volumes, including explicit Secret, ConfigMap, and PVC references. |
| `volumeMounts` | `list(object)` | no | Container mounts; separate from PVC resource declarations. |
| `initContainers` | `map(object)` | no | Named init containers; receive the workload environment and inherit mounts unless explicitly set. |
| `sidecars` | `list(object)` | no | Extra containers; receive the workload environment. |
| `livenessProbe`, `readinessProbe` | `object` | no | HTTP probes using the named `http` port by default. |
| `podSecurityContext`, `securityContext` | `object` | no | Pod and container security; defaults use user/group `1001` and a read-only container root filesystem. |
| `automountServiceAccountToken` | `bool` | no | Pod token automount; shared default is `true`. Separate from the ServiceAccount's token setting. |
| `affinity`, `nodeSelector`, `tolerations` | `object` / `list(object)` | no | Pod scheduling settings; shared defaults include preferred pod anti-affinity. |
| `podLabels`, `podAnnotations` | `map(string)` | no | Additional pod metadata; generated selector labels are retained. |
| `revisionHistoryLimit` | `integer` | no | Retained workload revisions; shared default is `10`. |
| `strategy` | `object` | no | Deployment strategy; defaults to `RollingUpdate`, with `Recreate` for Compactor. |
| `serviceName`, `podManagementPolicy`, `updateStrategy` | `string` / `object` | no | StatefulSet identity and update settings; defaults are set per StatefulSet component. |
| `volumeClaimTemplates` | `map(object)` | no | StatefulSet claims; Store Gateway and Ruler default to an 8 GiB `data` claim. |

### `common.thanos` and `<component>.thanos`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `logLevel` | `string` | `info` | Logging level. |
| `logFormat` | `string` | `json` | Logging format. |
| `extraFlags` | `list(string)` or YAML `string` | `[]` | Additional templated CLI arguments; Compactor overrides this with `--delete-delay=48h`. |

Component settings override shared settings before the argument define is rendered.
An explicit `extraFlags: []` clears inherited flags. The five argument defines are
adapted from Bitnami Thanos chart 17.3.1.

### `query.thanos`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `replicaLabel` | `string` or `list(string)` | `[replica]` | Labels identifying replicated series. |
| `stores` | `list(string)` or YAML `string` | Templated internal discovery | StoreAPI endpoints. Supply a list to replace discovery; both forms support Helm templating. |

### `compactor.thanos`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `dataDir` | `string` | `/data` | Compaction data directory and data mount path. |
| `retentionResolutionRaw` | `string` | `30d` | Raw-resolution retention. |
| `retentionResolution5m` | `string` | `60d` | Five-minute-resolution retention. |
| `retentionResolution1h` | `string` | `90d` | One-hour-resolution retention. |
| `consistencyDelay` | `string` | `30m` | Delay before processing uploaded blocks. |
| `concurrency` | `integer` | `1` | Compaction concurrency. |
| `cronJob.enabled` | `bool` | `false` | Omit `--wait` when enabled; does not change the Deployment into a CronJob. |

### `ruler.thanos`

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `alertmanagers` | `list(string)` | yes | Nonempty Alertmanager URL list. |
| `queries` | `list(string)` | no | Query endpoints used for rule evaluation; defaults to `[]`. |
| `queryURL` | `string` | no | Query UI URL used in alert links; defaults to `https://tq.<global.env.dns.domain>`. Supports Helm templating. |
| `dataPath` | `string` | no | Rule data directory and mount path; defaults to `/data` when empty. |
| `evalInterval` | `string` | no | Rule evaluation interval; defaults to `1m`. |
| `replicaLabel` | `string` | no | Replica label; defaults to `replica`. |
| `clusterName` | `string` | no | Ruler cluster label; defaults to an empty string. |
| `ruleFile` | `string` | no | Rule-file pattern; defaults to `/conf/rules/*.yml`. |

Provide the rules ConfigMap separately. Its default name is
`<stack-fullname>-ruler`, and it is mounted at `/conf/rules`. The chart does not
create this ConfigMap or generate a checksum annotation for its contents.

## Outputs

The chart renders Kubernetes resources rather than Helm output values.

| Resource | Created from |
|----------|--------------|
| `Deployment` | Enabled Query, Query Frontend, and Compactor components. |
| `StatefulSet` | Enabled Store Gateway and Ruler components. |
| `Service` | Each enabled component's primary Service and enabled `additionalServices` entries. |
| `ServiceAccount` | Enabled components whose effective `serviceAccount.create` is `true`. |
| `Secret` | Stack `secrets` and enabled components' Secret declarations. |
| `PersistentVolumeClaim` | Enabled components' `pvcs`; StatefulSets also provision claims through their claim templates. |
| `NetworkPolicy` | Enabled components with their effective policy enabled. |
| `PodDisruptionBudget` | Enabled components with their effective budget enabled. |
| `ServiceMonitor` | Enabled components with their effective monitoring enabled. |
| `Ingress` | Enabled Query/Store Gateway ingresses and enabled `additional_ingress` entries. |
| `KongPlugin` / `KongClusterPlugin` | Plugin definitions when the Kong dependency is enabled. |

HPAs, ConfigMaps, object-storage buckets, and Receive workloads are not generated.
