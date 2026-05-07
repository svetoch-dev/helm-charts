# grafana-serviceaccounts

Helm chart for creating `GrafanaServiceAccount` resources managed by the Grafana Operator.

The chart renders one `grafana.integreatly.org/v1beta1` `GrafanaServiceAccount` per enabled entry in `grafanaServiceAccounts`.

## Values

| Value | Required | Description |
| --- | --- | --- |
| `grafanaServiceAccounts` | no | Map of service account resources keyed by Kubernetes resource name. |
| `grafanaServiceAccounts.<name>.enabled` | yes | Enables rendering for this service account. |
| `grafanaServiceAccounts.<name>.instanceName` | yes | Grafana instance name where the service account should be created. |
| `grafanaServiceAccounts.<name>.name` | no | Service account name inside Grafana. Defaults to the map key. |
| `grafanaServiceAccounts.<name>.role` | yes | Grafana role. Must be `Viewer`, `Editor`, or `Admin`. |
| `grafanaServiceAccounts.<name>.isDisabled` | no | Whether the service account is disabled. |
| `grafanaServiceAccounts.<name>.suspend` | no | Pauses reconciliation when set to `true`. |
| `grafanaServiceAccounts.<name>.resyncPeriod` | no | Operator resync period, for example `30m`. |
| `grafanaServiceAccounts.<name>.tokens` | no | List of tokens to create for the service account. |

String fields are passed through Helm `tpl`, so values can reference global or release values.

## Example

```yaml
grafanaServiceAccounts:
  grafana-admin-automation:
    enabled: true
    instanceName: main
    name: automation
    role: Admin
    resyncPeriod: 30m
    tokens:
      - name: automation-token
        secretName: grafana-admin-automation-token
```

This renders:

```yaml
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaServiceAccount
metadata:
  name: grafana-admin-automation
spec:
  instanceName: main
  name: automation
  role: Admin
  resyncPeriod: 30m
  tokens:
    - name: automation-token
      secretName: grafana-admin-automation-token
```

## Parent chart usage

The parent `charts/grafana` chart exposes this chart with the `serviceaccount` alias:

```yaml
serviceaccount:
  enabled: true
  grafanaServiceAccounts:
    grafana-viewer-automation:
      enabled: true
      instanceName: main
      role: Viewer
```

## Render locally

```shell
helm template test charts/chart_deps/grafana/serviceaccounts \
  --set grafanaServiceAccounts.example.enabled=true \
  --set grafanaServiceAccounts.example.instanceName=main \
  --set grafanaServiceAccounts.example.role=Viewer
```
