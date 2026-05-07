# grafana-operated

Helm chart for creating a `Grafana` resource managed by the Grafana Operator.

The chart renders one `grafana.integreatly.org/v1beta1` `Grafana` custom resource. Most values are passed directly into `spec`, so the chart can be used to configure the Grafana instance without duplicating the operator schema.

## Values

| Value | Required | Description |
| --- | --- | --- |
| `selector` | no | Extra labels added to the `Grafana` resource metadata. Commonly used by related operator resources to target this instance. |
| `version` | no | Grafana version written to `spec.version`. |
| `client` | no | Passed to `spec.client`. |
| `config` | no | Passed to `spec.config`. |
| `deployment` | no | Passed to `spec.deployment`. |
| `resources` | no | Resource requests and limits for the `grafana` container. If `deployment.spec.template.spec.containers` already contains a container named `grafana`, the chart adds these resources to it. Otherwise, it creates or appends a `grafana` container with the resources. |
| `external` | no | Passed to `spec.external`. |
| `ingress` | no | Passed to `spec.ingress`. |
| `jsonnet` | no | Passed to `spec.jsonnet`. |
| `persistentVolumeClaim` | no | Passed to `spec.persistentVolumeClaim`. |
| `route` | no | Passed to `spec.route`. |
| `service` | no | Passed to `spec.service`. |
| `serviceAccount` | no | Passed to `spec.serviceAccount`. |

Values rendered under `spec` are passed through Helm `tpl`, so strings can reference global or release values.

## Example

```yaml
selector:
  grafana: main

version: "12.3.3"

config:
  log:
    mode: console
  log.console:
    format: json
  users:
    allow_sign_up: "false"
    default_theme: dark
  server:
    root_url: https://gf.example.com

resources:
  requests:
    cpu: 50m
    memory: 100Mi
  limits:
    cpu: 3000m
    memory: 500Mi

deployment:
  spec:
    template:
      metadata:
        labels:
          app.kubernetes.io/instance: grafana-main
      spec:
        containers:
          - name: grafana
            env:
              - name: GF_AUTH_JWT_ENABLED
                value: "true"
```

This renders:

```yaml
apiVersion: grafana.integreatly.org/v1beta1
kind: Grafana
metadata:
  labels:
    app.kubernetes.io/name: grafana-operated
    app.kubernetes.io/instance: test
    grafana: main
  name: test-grafana-operated
spec:
  version: 12.3.3
  config:
    log:
      mode: console
    log.console:
      format: json
    users:
      allow_sign_up: "false"
      default_theme: dark
    server:
      root_url: https://gf.example.com
  deployment:
    spec:
      template:
        metadata:
          labels:
            app.kubernetes.io/instance: grafana-main
        spec:
          containers:
            - name: grafana
              env:
                - name: GF_AUTH_JWT_ENABLED
                  value: "true"
              resources:
                requests:
                  cpu: 50m
                  memory: 100Mi
                limits:
                  cpu: 3000m
                  memory: 500Mi
```

## Render locally

```shell
helm template test charts/chart_deps/grafana/grafana-operated \
  --set version=12.3.3 \
  --set selector.grafana=main \
  --set config.server.root_url=https://gf.example.com
```
