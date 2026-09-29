# Vedro controller dependency chart

This chart is based on `../vedro/helm/controller` at commit
`2eba2630979c6d9ff16b325248cf83035ab6d9a0` (version `0.1.0`). Its
`common` dependency points to this repository's `chart_deps/app/common`.

It is intended for composition in a stack chart. `controller.enabled` is true
inside this dependency, while the parent chart controls whether the entire
dependency is enabled. The Vedro CRDs are managed separately in `crds/vedro`.

The upstream Prometheus rules expect `global.env.short_name`, and the
controller image defaults to `ghcr.io/svetoch-dev/vedro:v0.1.0`. When rendering
this chart outside the environment chart, set the required global values.
