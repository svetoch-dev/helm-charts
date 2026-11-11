# Thanos service

A reusable wrapper around [`app/common`](../../app/common). It sets the shared
Thanos image, command builder, probes, security, selectors, scheduling preference,
service ports, monitoring, NetworkPolicy settings, and StatefulSet storage defaults.
It renders workloads through common; it does not copy workload templates.

Configure the workload under `common`. The default component is `query`.
Supported `common.containerName` values are `query`, `query-frontend`, `compactor`,
`storegateway`, `ruler`, and `receive`. The stack chart selects the component,
workload kind, storage mounts, arguments, and other service-specific overrides.

```yaml
common:
  containerName: query
  stores:
    - prometheus-thanos:10901
```

The default args helper accepts `logLevel`, `logFormat`, and `extraFlags` under
`common`. It also reads query `stores`/`replicaLabel`, compactor retention settings,
ruler `alertmanagers`, and receive retention/replication settings. Override
`common.args` with a list or a templated YAML list for other Thanos flags.

StatefulSet defaults apply when `common.statefulsetEnabled` is true; disable
`common.deploymentEnabled` in that case. Keep existing selectors, service names,
and claim-template metadata when upgrading workloads.

The common chart's optional probes and Prometheus rules remain disabled by
default. ServiceMonitors and per-service NetworkPolicies are enabled for the stack.
Configure NetworkPolicy ingress rules for the service's ports in the consuming
chart. Resource requests and limits belong to the consuming service configuration.

Build this chart's dependencies before rebuilding consumers:

```sh
helm dependency build charts/chart_deps/thanos/service
helm dependency build charts/thanos
```
