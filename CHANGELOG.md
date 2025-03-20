# 9.0.0

Braking changes:
  * `cert-manager`: interface for creating `ClusterIssuer` obj have changed to using `certificates` chart in `chart_deps`
  * `konghq`: interface for creating `Issuer` and `Certificate` objs for webhooks have changed to using `certificates` chart in `chart_deps`
  * `gha-runner-scale-set`:
    * `gha-runner-scale-set-controller` moved to `gha-operator`
    * `gha-runner-scale-set` moved to `gha-runner`
    * delete securityContext from `gha-runner`

New features:
  * `chart_deps/app`: supports ability to turn off global variables (and global secret vars.).

Features:
  * `all charts`: new global attr `ingress.class`
  * `chart_deps/app/common`:  annotations can now use templates
  * `chart_deps/security/certificates`:
    * ability to create `ClusterIssuers`
    * ability to create `Issuers`
    * `certs` are now dict
  * update `gha-operator` subchart and crds 0.9.3 -> 0.10.1
  * update `gha-runner` subchart 0.9.3 -> 0.10.1
  * update `kong` subchart and crds 2.37.1 -> 2.47.0

Enchancements:
  * `chart_deps/konghq/plugins`: use templates in plugin names

# 8.3.1

fixes:
  * `kong`: webhook certificate resource name add `webhook` suffix

# 8.3.0

fixes:
  * `kong`: webhook certificate resource name is now set based on release name
  * `kong`: create webhook cert if admissionWebhook is enabled and admissionWebhook.useCertmanager is true

# 8.2.0

New features:
  * `chart_deps/app`: support for pv static provisioning

# 8.1.0

New features:
  * `postgres`:
    * update postgres-operator subchart 1.10.1 -> 1.14.0
    * move backup bucket templates to chart values

# 8.0.0

Breaking changes:
  * `argocd,cert-manager,thanos,grafana,prometheus,prometheus`:
    * `global.company.gcp` attribute is removed
    * `global.company.bucket` moved to `global.bucket`
    * `global.company.network` is moved to `global.network`
  * `environment,environments`:
    * `company.gcp` attr is removed
    * `company.network` moved to `network`
    * `company.bucket` moved to `bucket`
  * `environments`:
    * `defaultValuesTpl` adjusted in order to reflect `environment` chart changes
  * `prometheus`:
    * remove ingress specific annotations

New features:
  * `argocd,cert-manager,thanos,grafana,prometheus,prometheus`:
    * new global attribute - registry
  * `environment`:
    * new attribute - registry

# 7.2.0
New features:
  * `thanos`:
    * ability to create kong plugins
    * common global values
  * `environment`: new var externalEnvDomains

# 7.1.0
New features:
  * `environments`: new `defaultValuesTpl` variable used to set common env attributes

# 7.0.1
Enhancements:
  * `environment`: move externalRedis attribute to argocd default values
  * `chart_deps/prometheus/prometheus-rules`: use tpl function for alert.env attr

# 7.0.0
Breaking changes:
  * `argocd/cert-manager/prometheus/grafana`: use global structure same as environment chart globals
  * `prometheus`:
    * `stackdriver-exporter:`: service account creation in chart disabled. Instead use already created ones
    * `chart_deps/prometheus/alertmanager-configs`:
      * render template per attr in spec not the whole spec itself
      * use tpl for route,inhibitRules,muteTimeIntervals
      * ability to set default alert provider configs
    * `PrometheusAlerts.prometheus-main`: disable all alerts by default + remove pubsub alert

New features:
  * `grafana`:
    * move `Api_calls_total` panel from `PubSub subscription`
    * new panel `Number of logs`
    * subchart update `grafana-operator` and crds `v5.12.0` to `v5.14.0`
  * `prometheus`:
    * new alert `To_many_gcp_logs`
    * subcharts updates:
      * `prometheus-stackdriver-exporter` `v4.6.0` to `v4.6.2`
      * `prometheus-blackbox-exporter` `v9.0.0` to `v9.0.1`
      * `prometheus-node-exporter` `v4.39.0` to `v4.41.0`
      * `kube-state-metrics` `v4.2.13` to `v4.2.14`
      * `kube-prometheus-stack` `v62.6.0` to `v65.5.1`
    * update prometheus-operator crds `v0.76.1` to `v0.77.2`
  * `actions-runner-controller`:
    * added `gha-runner-scale-set-controller` and `gha-runner-scale-set` for github self-hosted runners

Fixes:
  * `grafana`: fix variable `service`

# 6.0.0
Breaking changes:
  * `argocd/thanos/prometheus`: service account creation in chart disabled. Instead use already created ones
  * `thanos`: remove env specific info from chart

Enhancements:
  * `grafana`: introduce `global.env.name` attr to set env related params
  * `argocd`: set prober url in chart values

# 5.1.0
New features:
  * `argocd`:
    * add probes as dependency chart
    * add argocd server probe
  * `environment`: argocd default value for blackbox exporter host name

Enhancements:
  * `chart_deps/prometheus/probes`: tpl for probes.spec

# 5.0.2
Enhancements:
  * `chart_deps/common/app`: `image.repository` attribute can be set globally

# 5.0.1
Enhancements:
  * `chart_deps/common/app`: tpl all env related attributes

# 5.0.0
Breaking changes:
  * project directory structure has changed
    * all chart related code is now under charts dir
  * `charts/environment and charts/environments`:
    * moved all folder related options of `repository` attr to `repository.paths`

New features:
  * `charts/environment and charts/environments`:
    * path rendering are now wraped in tpl function

# 4.4.0
New features:
  * `chart_deps/apps/common`:
    * initContainers support
    * pvc support
  * `postgres`:
    * pgadmin service

# 4.3.0

New features:
  * `prometheus`:
    * add `prometheus-stackdriver-exporter v4.6.0`
    * subcharts updates:
      * `prometheus-node-exporter v4.37.0` to `v4.39.0`
      * `prometheus-blackbox-exporter v8.17.0` to `v9.0.0`
      * `kube-prometheus-stack v60.4.0` to `v62.6.0`
      * `kube-state-metrics v4.2.5` to `v4.2.13`
      * `thanos v0.35.1` to `v0.36.1`
    * `prometheus v2.53.0` updated to `v2.54.1`
    * add alert `Pubsub_subscription_unacknowledged_messages`
  * `thanos` chart: subcharts `v15.7.10` updated to `v15.7.25`
  * `prometheus-operator' + 'crds v0.75.0` updated to version `v0.76.1`
  * added new common dashboard `common-google-cloud-dashboard` (`Google-cloud`) to `grafana`

# 4.2.0

New features:
  * `redis-operator` update to `v1.3.0`
  * `redis-operator crds` update to `v1.3.0-rc1`
  * `argo-cd`:
    * added `redis` to `argocd chart`
    * subcharts update
      * `argo-cd crds v2.10.4` to `v2.12.2`
      * `argo-cd v6.7.3` to `v7.4.5`
  * `grafana`:
    * added new panel `Top 5 tables by insert`
    * added new panel `Top 5 tables by update`
    * added new panel `Top 5 tables by delete`
    * added new panel `Top 5 tables by Heap-Only Tuples (HOT) update`
    * added new panel `Top 5 tables by not Heap-Only Tuples (HOT) update`
    * added new panel `Size of tables`
    * added new panel `Rows waiting for vacuum (Estimated number of dead rows)`
    * added new panel `Top 5 transactions by duration`
    * added new panel `Number of query executions`
    * added new panel `Total number of rows received or affected by the operator (Top 5)`

Fixes:
  * fix script `GKE_upgrade` (if the user refused to delete the pdb, the script stopped working)
  * `grafana pg panels`
    * fix `master panel` (at the moment of switching the pg master, a situation occurs when there are metrics of one pod on two nodes, and the metrics cannot be connected at this moment, at such moments, graphic broke down)
    * fix `master+slave metrics` (pg metrics were output from the master and slave, now only from the master)
    * fix `sum of duplicated metrics` (fixed possible summation of duplicate metrics)

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

Breaking changes:
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

Breaking changes:
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
