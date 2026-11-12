# Thanos service resources

A reusable wrapper around [`app/common`](../../app/common). Keep that dependency's
original name `common`: Helm 3 can mishandle a nested alias when this wrapper is
used repeatedly under different parent aliases.

Configure native Kubernetes resources under `common`. The consuming chart supplies
`common.command` and `common.args`; this wrapper has no CLI defaults. Thanos
application settings used by argument defines live under `common.thanos`, exposed
to the nested chart as `.Values.thanos`.

```yaml
common:
  containerName: query
  args:
    - query
    - --http-address=0.0.0.0:10902
```

StatefulSet defaults apply when `common.statefulsetEnabled` is true; disable
`common.deploymentEnabled` in that case. Preserve selectors, governing Service
names, and claim-template metadata when upgrading workloads.

The common chart's optional probes and Prometheus rules remain disabled by
default. ServiceMonitors and NetworkPolicies are enabled for the stack. Configure
ingress policy, resource requests/limits, and storage mounts per component.
Kubernetes Service configuration is under `common.service`.

Build dependencies before rebuilding consumers:

```sh
helm dependency build charts/chart_deps/thanos/service
helm dependency build charts/thanos
```
