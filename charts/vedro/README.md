# Vedro

This stack chart can deploy the Vedro controller and its cloud resources. Both
dependencies are disabled by default. Vedro CRDs are managed separately in
`crds/vedro` and must be applied before enabling the controller or resources.

Enable the controller with `vedro-controller.enabled: true`. Its remaining
values pass through to the local `vedro-controller` dependency. The controller
templates require `global.env.short_name` and `global.company.name`; the
environment chart supplies these through `charts/globals.yaml` and environment
values. Set them explicitly when rendering this chart on its own.

Set `vedro-resources.enabled: true` and configure `providers`, `principals`,
and `buckets` under `vedro-resources` to manage resources independently of the
controller. The resource dependency can also be used directly in application
charts from `charts/chart_deps/vedro/vedro-resources`.

Like other stack charts in this repository, this chart commits `Chart.lock`
without generated archives under `charts/vedro/charts`. Run
`helm dependency build charts/vedro` before a local `helm template` from a
clean checkout.
