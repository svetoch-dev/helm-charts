# Helm charts

## Environment chart behavior

Environments are enabled by default. Set `global.envs.<key>.enabled: false`
explicitly to prevent the chart from generating that environment Application.

Repository revisions use the following precedence, from highest to lowest:

1. `chart_apps.<app>.revision` for one application;
2. `global.envs.<key>.revision` for an environment and all applications in it;
3. `global.repo.revision` as the common default; it defaults to `master` when
   omitted.

`global.ci` is passed only to the environment with `type: internal`. Product
environments do not receive CI configuration.

The chart derives `global.env.cloud_short_name` as
`<global.env.cloud.name>-<global.env.short_name>`. For example, an environment with
`cloud.name: gcp` and `short_name: int` gets `cloud_short_name: gcp-int`.

`cloud_short_name` is used for:

* Argo CD Application and Helm release names;
* environment override directories such as `argocd/environments/gcp-int`;
* Kubernetes resource and Service references;
* log labels and datasource UIDs.

Both `global.envs.<key>.dns.type` and `global.envs.<key>.dns.provider` are
optional. The `environments` chart derives the provider for known DNS types:
`gcp` maps to `google`, `yc` maps to `webhook`, `aws` maps to `aws`, and
`cloudflare` maps to `cloudflare`. The resolved provider is passed to the child
chart as `external-dns.provider`.

An explicit provider overrides the default derived from the DNS type. If neither
a known type nor a provider is set, `dns.provider` is passed as an empty string.
Set it to an identifier supported by the selected external-dns chart version when
provider configuration is required.

`global.env.cloud.buckets.type` is derived from `global.env.cloud.name`: `gcp`
maps to `gcs`, while `yc` and `aws` map to `s3`. An explicitly configured bucket
type overrides the derived value. For other cloud names without an override, the
bucket type is passed as an empty string.

The environment chart passes the common `global` object to every child
Application and merges `chart_apps.<app>.globalValues` over it.

For an environment with `type: internal`, the environments chart automatically
creates `externalEnvs` from all enabled environments with `type: product`. Keys use
the external environment's `cloud_short_name`, for example:

```yaml
externalEnvs:
  gcp-prd:
    domain: prd.example.com
```

## Generated application defaults

Entries under `global.envs.<key>.apps` generate application defaults for the
`environment` chart. Generated applications are enabled by default, set
`app: true`, grant the `admin` and `dev` roles, and use `global.ingress.class`
as the ingress class.

Generated application defaults are configured through `default_apps_values` in the
`environment` chart values. Override this object in an environment `env.yaml` to
change defaults for all generated applications in that environment.

The generated Argo CD Application name uses the app `name` field and falls back
to the app key when `name` is omitted. The namespace is resolved in this order:

1. `appOverrides.<key>.namespace` in the environment's `env.yaml`;
2. `global.envs.<key>.apps.<app>.namespace`;
3. `global.envs.<key>.apps.<app>.name`;
4. the app key.

The `postgres`, `rabbitmq`, and `redis` flags generate the corresponding service
references and must be YAML booleans. When the application chart key differs from
the app key, set `appOverrides.<key>.chart_name` in the environment's `env.yaml`.
Explicit `chart_apps` values are merged over the generated defaults and remain
available for application-specific configuration.

An application grants access when a user's role is present in that application's
`global.access.roles`. A wildcard user grants domain-wide access:

```yaml
users:
  all:
    name: "*@example.com"
    roles: [dev]
```

This allows every current or future address in `example.com` to access every
application that includes the `dev` role. It is broader than listing individual
users.

## Structure
* there are highlevel charts and charts that are used as a dependency to highlevel charts
* highlevel charts represent a service or stack (for example konghq, prometheus)
* Chart that are used as dependencies (dependency charts) are placed in `charts/chart_deps` folder 
* highlevel chart is a subset of external or dependency (the ones in `charts/chart_deps`) charts

## TBD
* Add docs for each chart

## More info

Checkout https://github.com/ggramal/infrared for more info

## Prerequisites
Before doing anything in this repo please follow this steps
1. Install pre-commit `pip install pre-commit`
2. Clone this project
3. Run `pre-commit install` from the project dir
