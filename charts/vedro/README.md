# Vedro

Composes the upstream [controller](https://github.com/svetoch-dev/vedro/tree/master/helm/controller)
and [resource chart](https://github.com/svetoch-dev/vedro/tree/master/helm/vedro),
both pinned to `0.1.0` from `oci://ghcr.io/svetoch-dev/charts`.

`vedro-controller` and `vedro-resources` are disabled by default. Providers,
principals and buckets must be configured explicitly.

## Standalone Application

Merge into the environment's `env.yaml`:

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

In `environments/<env>/vedro/values.yaml`, enable the controller and add the
[resource values](#resource-values) below:

```yaml
vedro-controller:
  enabled: true
  controller:
    serviceAccount:
      create: false
      name: vedrosa
```

KSA `vedro/vedrosa` must already have the controller's cloud identity configured.
Install `crds/vedro` before syncing custom resources. Keep its version aligned
with the upstream charts.

## Inside an application

Add to the application's `Chart.yaml` dependencies, then update its `Chart.lock`:

```yaml
  - name: vedro
    version: 0.1.0
    repository: oci://ghcr.io/svetoch-dev/charts
    alias: vedro-resources
    condition: vedro-resources.enabled
```

Add the same resource values below to the application's values. The existing
controller handles them; no additional controller or Argo CD Application is
needed.

## Resource values

GCP Workload Identity example. App-of-Apps supplies `global.env.cloud`.
KSA `app` must exist in the release namespace; Vedro maps it to the managed GSA.
For GCP, `managed.name` must be 6–30 characters.

```yaml
vedro-resources:
  enabled: true
  providers:
    primary:
      name: "{{ .Release.Name }}"
      type: "{{ .Values.global.env.cloud.name }}"
      projectId: "{{ .Values.global.env.cloud.id }}"
      region: "{{ .Values.global.env.cloud.location.region }}"
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
      provider: "{{ .Release.Name }}"
      kind: ServiceAccount
      type: Managed
      managed:
        name: "{{ .Release.Name }}-app"
        deletionPolicy: Delete
      auth:
        method: WorkloadIdentity
        workloadIdentity:
          serviceAccountRef:
            name: app
  buckets:
    data:
      provider: "{{ .Release.Name }}"
      location: "{{ .Values.global.env.cloud.location.region }}"
      prefixReleaseName: true
      deletionPolicy: Delete
      objAdmins:
        - name: app
```

This creates one provider, one GSA with its KSA mapping, and bucket
`<release>-data` with object administration access. ProviderConfig is cluster
scoped; its release-based name avoids ownership conflicts between applications.

Use `Retain` instead of `Delete` to preserve cloud resources after removing their
custom resources. During deletion, keep the controller and provider available
until cleanup finishes. See the upstream resource chart for other access levels
and authentication methods.
