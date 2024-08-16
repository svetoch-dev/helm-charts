# 4.2.0

New features:
  * `Redis-operator` update to `v1.3.0`
  * `Redis-operator crds` update to `v1.3.0-rc1`

# 4.1.2

Fixes:
  * Adjust hpa to autoscaling/v2 interface

# 4.1.1

Fixes:
  * autoscaling/v2 for hpa common helm charts

# 4.1.0

New features:
  * `grafana`:
    * added new `traffic` dashboards for `nodes` and `containers`
    * added the ability to view `PG connections by type` on the `Connection count` panel
    * added new panel `PG replication lag`
    * added the ability to view `PG dbs size` on the `PVC usage` panel
    * subcharts update
      * `grafana-operator v5.9.2` to `5.12.0`
      * `grafana crds v5.9.2` to `5.12.0`
Fixes:
  * fix `grafana appVersion` from `9.5` to `10.4` 

# 4.0.3 

New features:
  * `Prometheus`:
    * new common alerts:
      * `Chainlink_node_states` (disabled by default)
      * `Chainlink_multi_node_states` (disabled by default)
    * subcharts update
      * `prometheus-node-exporter` to `4.37.0`


# 4.0.2

Enhancements:
  * `grafana`:
    * services dashboard - redis observability improvements
      * number of masters/slaves pannel
      * sentinel clients + sentinel current master
  * `Prometheus`
    * new common alerts:
      * `Redis_missing_master`
      * `Redis_too_many_masters`
      * `Redis_disconnected_slaves`


# 4.0.1

Fixes:
  * `grafana`:
    * fix `incorrect display of max_connections on postgres panel when using more than 1 pg-exporter`
  * `Prometheus`:
    * fix alert `Available_postgresql_connections_are_running_out` for proper processing when using more than 1 pg-exporter
    * fix alert `Available_postgresql_connections_are_running_out` the number of connections was displayed as a percentage

New features:
  * add folder with `scripts`

  
# 4.0.0

Braking changes:
  * `chart_deps/prometheus/prometheus-rules`: Chart attribute `PrometheusAlerts.prometheus-main.AbsentMetricCritical` type changed from list to dict

New features:
  * `Prometheus`:
    * new common alert `Statefulset_not_ready`
    * new common alert `DB_transactions_per_seconds_below_norm`
    * new common alert `ErrorRateIncreasedFor_5XX`
    * new common alert `api`
    * new commin alert `Postgres_replica_is_down`
    * new commin alert `Postgres_is_down`
    * new common `AbsentMetricCritical` alerts
    * Critical/Warning group of alerts can be disabled using the option .enabled: false
    * subcharts update
      * `prometheus-node-exporter` to `4.36.0`
      * `kube-prometheus-stack` to `60.4.0`
      * `kube-state-metrics` to `4.2.5`
      * `thanos` updated to `v0.35.1`
    * `prometheus-operator` updated to version `v0.75.0`
    * `prometheus` updated to `v2.53.0`
  * `thanos` chart: subcharts updated to `15.7.10`

Fixes:
  * `grafana`:
    * fix `some pods were not displayed`


# 3.1.0

New features:
  * `Grafana-operator` update to `v5.9.2`
  * `Grafana crds` update to `v5.9.2`
  * `Grafana` update to `v10.4.3`

Fixes:
  * `grafana`: 
    * fix `found duplicate series for the match group`  on `PG master role` dashboard
    * fix `multiple matches for labels: many-to-one matching must be explicit` on `Mem usage per node` dashboard
    * fix not displayed memory limit on `Mem usage per node` dashboard for some pods
    * perhaps fix `multiple matches for labels: many-to-one matching must be explicit` on `CPU usage per node` dashboard


# v3.0.2

Enhancement:
  * `prometheus`: 
    * New attribute `keep_firing_for` is added for alert rules
    * Change increase period for `Container_too_many_restarts` alert


# v3.0.1

Fixes:
  * `grafana`: fix `User exists` issues with oauth login https://github.com/grafana/grafana/issues/70203#issuecomment-1603895013


# v3.0.0

Braking changes:
  * `chart_deps/prometheus/prometheus-rules`: Chart attribute `PrometheusAlerts.prometheus-main.CriticalMetric` and `PrometheusAlerts.prometheus-main.WarningMetric` type changed from list to dict

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
