# grafana-operated

Helm chart for creating a `Grafana` resource managed by the Grafana Operator.

The chart renders one `grafana.integreatly.org/v1beta1` `Grafana` custom resource. Most values are passed directly into `spec`, so the chart can be used to configure the Grafana instance without duplicating the operator schema.

## Values

| Value | Required | Description |
| --- | --- | --- |
| `selector` | no | Extra labels added to the `Grafana` resource metadata. Commonly used by related operator resources to target this instance. |
| `labels` | no | Labels added to `spec.deployment.spec.template.metadata.labels`. |
| `version` | no | Grafana version written to `spec.version`. |
| `client` | no | Passed to `spec.client`. |
| `config` | no | Passed to `spec.config`. |
| `deployment` | no | Passed to `spec.deployment` and merged with the rendered pod template values. Use this for raw Grafana Operator deployment fields or to override generated pod template fields. |
| `podAnnotations` | no | Annotations added to `spec.deployment.spec.template.metadata.annotations`. |
| `imagePullSecrets` | no | Image pull secrets added to `spec.deployment.spec.template.spec.imagePullSecrets`. |
| `serviceAccountName` | no | Service account name added to `spec.deployment.spec.template.spec.serviceAccountName`. |
| `restartPolicy` | no | Restart policy added to `spec.deployment.spec.template.spec.restartPolicy`. |
| `podSecurityContext` | no | Pod security context added to `spec.deployment.spec.template.spec.securityContext`. |
| `initContainers` | no | Init containers added to `spec.deployment.spec.template.spec.initContainers`. |
| `securityContext` | no | Security context for the generated `grafana` container. |
| `imagePullPolicy` | no | Image pull policy for the generated `grafana` container. |
| `command` | no | Command for the generated `grafana` container. |
| `args` | no | Arguments for the generated `grafana` container. |
| `resources` | no | Resource requests and limits for the generated `grafana` container. |
| `environment` | no | Environment variables added to the generated `grafana` container as `env`. |
| `ports` | no | Ports for the generated `grafana` container. |
| `livenessProbe` | no | Liveness probe for the generated `grafana` container. |
| `readinessProbe` | no | Readiness probe for the generated `grafana` container. |
| `volumeMounts` | no | Volume mounts for the generated `grafana` container. |
| `nodeSelector` | no | Node selector added to `spec.deployment.spec.template.spec.nodeSelector`. |
| `affinity` | no | Affinity added to `spec.deployment.spec.template.spec.affinity`. |
| `tolerations` | no | Tolerations added to `spec.deployment.spec.template.spec.tolerations`. |
| `volumes` | no | Volumes added to `spec.deployment.spec.template.spec.volumes`. |
| `external` | no | Passed to `spec.external`. |
| `ingress` | no | Passed to `spec.ingress`. |
| `jsonnet` | no | Passed to `spec.jsonnet`. |
| `persistentVolumeClaim` | no | Passed to `spec.persistentVolumeClaim`. |
| `route` | no | Passed to `spec.route`. |
| `service` | no | Passed to `spec.service`. |
| `serviceAccount` | no | Passed to `spec.serviceAccount`. |

Values rendered under `spec` are passed through Helm `tpl`, so strings can reference global or release values.

The generated pod template is based on `core.podtemplate`. The chart sets the main container name to `grafana` and omits the container image because Grafana Operator manages it through `spec.version`. If a pod or container security context is not set, the chart omits that empty object from the Grafana custom resource.

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

labels:
  app.kubernetes.io/instance: grafana-main

environment:
  - name: GF_AUTH_JWT_ENABLED
    value: "true"

nodeSelector:
  cloud.google.com/gke-nodepool: monitoring

tolerations:
  - key: dedicated
    operator: Equal
    value: monitoring
    effect: NoSchedule
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
          nodeSelector:
            cloud.google.com/gke-nodepool: monitoring
          tolerations:
            - key: dedicated
              operator: Equal
              value: monitoring
              effect: NoSchedule
          containers:
            - name: grafana
              imagePullPolicy: IfNotPresent
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
