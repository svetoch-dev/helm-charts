# v3.0.0

Braking changes:
  * `chart_deps/prometheus/prometheus-rules`: Chart attribute `PrometheusAlerts.CriticalMetric` and `PrometheusAlerts.WarningMetric` type changed from list to dict

New features:
  * `environment,environments`: now support company related attributes and set company related fields
  * `prometheus-operator`: updated to version `v0.74.0`
  * `thanos` chart: subcharts updated to `15.5.0`
  * `prometheus` chart:
    * `prometheus` updated to `v2.52.0`
    * `alertmanger-configs` main has now default inhibition rules
    * `alertmanager`: version updated to `v0.27.0`
    * `global.domains` `global.envs` new attributes
    * Default Critical/Warning alerts
    * `thanos` updated to v0.35.0
    * subcharts update
      * `prometheus-blackbox-exporter` to `8.17.0`
      * `prometheus-node-exporter` to `4.34.3`
      * `kube-state-metrics` to `58.7.2`
   
Enhancements:
  * `cert-manager`:
    * new `global.domain` attribute
  * `chart_deps/konghq/plugins`: now supports rendering helm templates in configs
  * `chart_deps/prometheus/prometheus-operated`: now supports helm templates in hosts attr for thanos-ingress
  * `grafana` services dashboard: updated pg master panel to show node on which master replica is running
