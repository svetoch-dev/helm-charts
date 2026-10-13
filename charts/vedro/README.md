# Vedro

Installs the Vedro controller and declares cloud principals, buckets and
access grants through the upstream [controller](https://github.com/svetoch-dev/vedro/tree/master/helm/controller)
and [resource chart](https://github.com/svetoch-dev/vedro/blob/master/helm/vedro/README.md).

## Usage

### Standalone Application

Enable the chart and its CRDs in `environments/<env>/env.yaml`:

```yaml
chart_apps:
  vedro:
    enabled: true
    namespace: vedro
crds:
  enabled: true
  operators:
    vedro:
      enabled: true
```

Set `environments/<env>/vedro/values.yaml`:

```yaml
vedro-controller:
  enabled: true
  controller:
    serviceAccount:
      create: false
      name: vedrosa

vedro-resources:
  enabled: true
  providers:
    primary:
      type: gcp
      projectId: my-project
      region: europe-west1
      method: WorkloadIdentity
      usagePolicy:
        allowedNamespaces:
          names: ["{{ .Release.Namespace }}"]
        bucketPolicy:
          allowedNamePatterns: ["^{{ .Release.Name }}-.*$"]
        principalPolicy:
          allowedNamePatterns: ["^{{ .Release.Name }}-.*$"]
  principals:
    app:
      provider: primary
      kind: ServiceAccount
      type: Managed
      managed:
        name: example-app
        deletionPolicy: Delete
  buckets:
    data:
      provider: primary
      location: europe-west1
      prefixReleaseName: true
      deletionPolicy: Delete
      admins:
        - name: app
    archive:
      provider: primary
      location: europe-west1
      prefixReleaseName: true
      deletionPolicy: Retain
      readers:
        - name: app
```

The controller uses the existing KSA `vedro/vedrosa`. This creates one cloud
service account and two buckets: `<release>-data` with bucket administration
access, and `<release>-archive` with object read access for that account.

## Requirements

- Install Vedro CRDs before syncing resources; App-of-Apps manages them separately.
- Configure the controller's KSA-to-CloudSA Identity(Workload, Federation) mapping and cloud IAM
  permissions before use. The chart does not grant the controller cloud permissions.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `vedro-controller.enabled` | Install the controller and its Kubernetes RBAC. | `false` |
| `vedro-resources.enabled` | Render cloud resource declarations. | `false` |
| `vedro-resources.providers` | Provider configurations and usage restrictions. | `{}` |
| `vedro-resources.principals` | Managed or existing cloud identities and optional authentication. | `{}` |
| `vedro-resources.buckets` | Buckets and their access grants. | `{}` |

See the upstream [resource inputs](https://github.com/svetoch-dev/vedro/blob/master/helm/vedro/README.md#type-details)
for all supported fields.
