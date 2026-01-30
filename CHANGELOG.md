# 11.0.0-alpha
BrakingChanges:
* `postgres-operator` uses configmaps instead endpoints (`kubernetes_use_configmaps: true`). See [UPGRADING](UPGRADING.md)

New features:
* `postgres-exporter` get query along with queryid

Enchancements:
* `postgres-operator`:
  * crds update 1.14.0 -> 1.15.1
  * chart update 1.14.0 -> 1.15.1
  * switch to using original `logical-backup` v1.15.1 image
* `postgres-exporter` update 0.17.1 -> 0.18.1

# 10.8.0
New features:
* add helm chart for `gitlab runner`

# 10.7.0
New features:
* `loki`: 
  * collect all loki metrics
  * `loki / *` pannels  in system dashboard
  * high api errors alert 

Enchancements:
* `loki`
  * limits increase `max_query_series`
  * chart update 6.49.0 -> 6.51.0
* `grafana`:
  * operator chart update 5.21.3 -> 5.21.4
  * grafana-main version update 12.3.1 ->  12.3.2


Fixes:
* Exclude bucket based fluentbit from fluentbit latency alert
* Fluentbit to many errors alert

# 10.6.0
Enchancements:
* `Prometheus`:
  * `disable` using `endpoints` for defaults (kubelet)
  * set `operator.prometheusOperator.enable` = `true` for default
  * chart updates:
    * `kube-prometheus-stack` 80.4.2 -> 81.2.2
    * `kube-state-metrics` 7.0.0 -> 7.1.0
    * `prometheus-blackbox-exporter` 11.6.1 -> 11.7.0
    * `prometheus-node-exporter` 4.49.2 -> 4.51.0
    * `postgres-exporter` 7.3.0 -> 7.4.0
  * image updates:
    * `alertmanager` 0.30.0 -> 0.30.1
    * `prometheus` 3.8.1 -> 3.9.1
  * crds updates:
    * `prometheus-operator` 0.87.1 -> 0.88.0
* `Rabbitmq`
  * move `rabbitmq-cluster-operator` bitnami chart to `chart_deps`
  * chart and crds updates 4.4.34 -> 4.4.37
  * images update:
    * `default-user-credential-updater` 1.0.8 -> 1.0.10
    * `cluster-operator` 2.16.1 -> 2.19.0
    * `messaging-topology-operator` 1.17.4 -> 1.18.2
* `Pomerium`
  * add rules for `endpointslices` in clusterRole
  * image and crds update 0.31.3 -> 0.32.0
  * set `cpu limits` 2 -> 1 and `cpu requests` 300m -> 50m
* update `gha-operator` crds + chart 0.13.0 -> 0.13.1
* update `gha-runner` chart 0.13.0 -> 0.13.1
* set more `buffer size` for `PG fluentbit-sidecar`
* `Postgres` logs rotation 24h -> 1h


# 10.5.0
New features:
* add support `postgres podMonitor` to get `fluentbit-sidecar metrics`
* add support `fluentbit-operated and fluentbit-standalone serviceMonitor` to get `fluentbits metrics`
* add `podMonitor` to prometheus lib
* add new `fluentbit alerts`
* add new `fluentbit panels` to grafana `system` dashboard

Enchancements:
* increase `pg-exporter` cpu limits 0.2 -> 0.4
* delete cpu limits for `redis` in `argocd`
* delete defaults cpu limits for `postgres` in `postgres-operator`
* delete `postgres logical backup` cpu limits

Fixes:
* fix `serviceMonitor` labels in `prometheus/lib`
* fix `fluentbit` `selectorLabels`

# 10.4.1
Enchancements:
* change count of restarts in alert `Container_too_many_restarts` to 5 in 10m

Fixes:
* `Prometheus`:
  * alert `Container_too_many_restarts` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Daemonset_not_ready` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `OOM_killed_pods` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Pod_replicas_not_ready` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Pods_waiting_state` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Statefulset_not_ready` many-to-many matching not allowed: matching labels must be unique on one side


# 10.4.0
Enchancements:
* delete `loki-read` cpu limits
* set `metadata.annotations` to `gha-runner workflow-pod`
* set `no-expose-internal-ipv6` for `external-dns`
* chart updates:
  * `cert-manager` 1.17.4 -> 1.19.2
  * `gha-operator` 0.11.0 -> 0.13.0
  * `gha-runner` 0.11.0 -> 0.13.0
  * `grafana` 5.19.0 -> 5.21.3
  * `kongqh` 2.48.0 -> 3.0.1
  * `loki` 6.42.0 -> 6.49.0
  * `prometheus`:
    * `kube-prometheus-stack` 77.0.2 -> 80.4.2
    * `kube-state-metrics` 6.1.5 -> 7.0.0
    * `prometheus-blackbox-exporter` 11.3.1 -> 11.6.1
    * `prometheus-node-exporter` 4.47.3 -> 4.49.2
    * `stackdriver-exporter` 4.10.0 -> 4.12.2
* image updates:
  * `alertmanager` 0.28.1 -> 0.30.0
  * `external-dns` 0.18.0 -> 0.20.0
  * `fluent-bit` 4.1.1 -> 4.2.0
  * `fluent-operator` 3.4.0 -> 3.5.0
  * `grafana` 12.1.1 -> 12.3.1
  * `pomerium/ingress-controller` 0.29.4 -> 0.31.3
  * `prometheus` 3.5.0 -> 3.8.1
* crds updates:
  * `cert-manager` 1.17.4 -> 1.19.2
  * `external-dns` 0.18.0 -> 0.20.0
  * `fluent-operator` 3.4.0 -> 3.5.0
  * `grafana-operator` 5.19.0 -> 5.21.3
  * `konghq` 3.3.0 -> 3.5.0
  * `pomerium` 0.29.0 -> 0.31.3
  * `prometheus-operator` 0.85.0 -> 0.87.1

Fixes:
* `Prometheus`:
  * alert `Postgres_logical_backup_error` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Container_too_many_restarts` many-to-many matching not allowed: matching labels must be unique on one side
  * alert `Statefulset_not_ready` many-to-many matching not allowed: matching labels must be unique on one side
  * use correct `prometheus-operator` name

# 10.3.1
Enchancements:
* `grafana`:
  * `services dashboard`: proper throttled pannels
* `promtheus`: fix throttled alerts + increase node exporter limits
* `chart_deps/rabbitmq/rabbitmq-cluster`: update default version to 4.2.2

# 10.3.0
Enchancements:
* `argocd`:
  * chart update 7.8.26 -> 9.1.7
  * crds update v2.14.10 -> v3.2.1
  * increase `server` memory limits 250Mi -> 350Mi
* `gha-operator` crds update 0.11.0 -> 0.13.0

Fixes:
* fixed default value type for `volumes` and `volumeMounts` in `fluentbit-standalone`
* fixed default value type for `job.environment`, `environment`, `volumes`, `volumeMounts` in `app/common`

# 10.2.3
Fixes:
* `grafana`:
  * `services dashboard`: fix datastore id issue

Enhancements:
* `loki`: tune performance parameters

# 10.2.2
Enhancements:
* `Prometheus`:
  * use `EndpointSlice` for default
  * delete deprecated `no_follow_redirects` in `blackbox-exporter`
* `grafana`
  * `services dashboard` total traffic pannels + counter for logs
  
Fixes:
* `Prometheus`:
  * alert `Container_too_many_restarts` many-to-many matching not allowed: matching labels must be unique on one side

New features:
* `Prometheus`:
  * ability to set `serviceDiscoveryRole`

# 10.2.1
Enchancements:
* set `loki` resources limits
* set 3Gb memory limit for `thanos storegateway`

# 10.2.0
Enhancements:
* `postgres`:
  * forced set `BACKUP_NUM_TO_RETAIN` to `5` days

New features:
* `postgres`:
  * add `fluent-bit` sidecar to stream logs
  * ability to set `additionalVolumes`
  * ability to set `volumeMounts` for `sidecars`
* `fluentbit secret` is created using `fluentbit-lib`

# 10.1.4
Enhancements:
* `charts/grafana`:
  * loki datastore timeouts increase
  * grafana pomerium timeout increase

# 10.1.3
Enhancements:
* `charts/grafana`: service dashboard - average latency pannels + show container iops/throughput for all disks
* `charts/konghq`: upstream_connect_time + connection_time in logs

# 10.1.2
Enhancements:
* `charts/kong`: tune `proxy_buffer` nginx params
* `charts/grafana`:  services dashboard -> kong -> upstream latency pannels

# 10.1.1
Enhancements:
* `charts/grafana`: service dashboard add konghq latency pannel

# 10.1.0
Enhancements:
* `charts/chart_deps/app/core`: core.ingress use same input types and implementation as other templates

Features:
* `charts/chart_deps/fluent/fluentbit/fluentbit-standalone`: ingress

# 10.0.3
Fixes:
* `charts/environment`: fix datasources for grafana if no external envs

# 10.0.2
Fixes:
* `charts/fluent`:
  * `fluentbit-gcp`:
    * reduce time for oldest processable file
  * `fluentbit`:
    * adjust `level_lower_case` lua func to handle lower case `warning`s

Enhancements:
* `charts/grafana`:
  * enable infinite scrolling

# 10.0.1
Fixes:
* `charts/fluent`:
  * `fluentbit-gcp`:
    * fix issue with hanging fluentbit after pod restarts
    * properly parse none milis timestamps
    * increase buffer_max_size

Enhancements:
* `charts/fluent`:
  * `fluentbit-main`:
    * use lua plugins to set common log levels

# 10.0.0

BrakingChanges:
* `chart_deps/postgres/postgres-cluster`:
  * `sidecars` attr now has dict type instead of list
  * `podMonitor.podMetricsEndpoints` attr now has dict type instead of list
* `chart_deps/grafana/datasources` now has dict type instead of list
* `chart_deps/grafana/dashboards` now has dict type instead of list
* `chart_deps/prometheus/alertmanager-configs`:
  * `useTpl` -> `useDefaults`
* `environments`: common env attributes are now under global section
* `environment`:
  * common env attributes are now under global section
  * new var `externalEnvs {}` instead of `externalEnvDomain []`
* `all charts`: global.admins -> global.teams.admin + qa,pm,dev groups to teams
* `grafana`: grafana domain name -> gf domain name
* `argocd`: argocd domain name -> ag domain name
* `thanos` uses official and updated image instead `bitnami`
* `external-dns` uses official and updated image instead `bitnami`
* `kube-state-metrics`:
  * uses official and updated image instead `bitnami`
  * uses `prometheus-community/helm-charts` instead `bitnami`
* `rabbitmq` uses official and updated images instead `bitnami`

New features:
* `environments`:
  * new cloud attr
* `environment`:
  * move thanos int configs to values.yaml 
  * thanos-external
  * `chart_apps`:  chart attribute can now be templated
* `fluent`: new chart for fluent operator + fluentbit
* new chart for `Loki` Simple Scalable Deployment
* `grafana`:
  * ability to set `uid` for grafana datasource
  * add new `datasource`, for `loki in int`
  * `datasources` for loki in all new env are created dinamically from `externalEnvs` variable
  * new panels for `logs` on `services dashboard`
  * new dashboard system
  * fluentbit filters chart
* `chart_deps/postgres/postgres-cluster`:
  * `defaultSidecars` attr that controls sets up pg exporter sidecars for each created db
  * ability to override `defaultSidecar` attrs by setting the keyNames same to db names
* `chart_deps/redis/redis-operator`:
  * `redis`: default exporter configs
  * `sentinel`: default exporter configs
* `chainlink-nodes`: global common env attrs
* `external-dns`: global common env attrs
* `gha-operator`: global common env attrs
* `gha-runner`: global common env attrs
* `redis`: global common env attrs
* `prometheus`:
  * move alertmanager-config defaults to `chart_deps/prometheus/alertmanager-configs` chart
  * move alertmanager-config `route` section to chart values
  * change default `AbsentMetricCritical` `for` time `30min -> 10min`
  * ability to set `for` for `AbsentMetricCritical` alert
* `chart_deps/prometheus/alertmanager-configs`:
  * slackConfigs to defaults
  * support go templates for receivers
  * default telegramConfigs
* `chart_deps/prometheus/alertmanager-operated`: externalUrl to `al.{{ .Values.global.domain.env }}`
* `chart_deps/prometheus/prometheus-operated`: externalUrl to `pm.{{ .Values.global.domain.env }}`
* `all charts`: 
  * global move global attributes to a separate file
  * use digest for images instead of plain tags
  * global attributes access and pomerium
* `rabbitmq`:
  * ability to set `image` (for default set `docker.io/rabbitmq:4.1.3`)
  * ability to set `rabbitmq: {}` values 
  * new alert `RabbitMQ_missing_master`
* `chart_deps/prometheus/lib`: library chart with prometheus operator object definitions
* `chart_deps/app/common`:
  * pvc/pv/deployment definitions moved to `chart_deps/app/core`
  * setviceMonitor definition moved to `chart_deps/prometheus/lib`
  * new secret definition
  * mount not only pvcs
  * statefulset creation
* `chart_deps/app/core`:
  * helper functions `core.labels.constructor` `core.obj.enricher`
  * new definitions pvc/pv/secret/deployment/statefullset
  * common `_podTemplate.tpl` definition
 

Enhancements:
* set `argocd controller` resources `limits memory` 2Gi -> 4Gi
* `cert-manager`: default ingress class is now pomerium
* `prometheus`:
  * default ingress class is now pomerium
  * update v3.2.1 -> v3.5.0
  * crds update v0.81.0 -> v0.85.0
  * new alert `RabbitMQ_too_many_masters`
  * new alert `pg_stat_activity_count` (AbsentMetricCritical)
  * alerts are arranged in alphabetical order
  * enable `metric-labels` for `statefulsets` and `daemonsets`
  * alert `Pods_waiting_state` was inhibited by active alerts `Statefulset_not_ready` or `Daemonset_not_ready`
  * all labels in description of alerts were put in quotation marks
  * use container/pod/namespace instead of exported_container/exported_pod/exported_namespace (deleted)
  * `CriticalMetric` alerts:
    * `Available_postgresql_connections_are_running_out` now it works when less than 30 connections are available (instead of 20)
    * `Daemonset_not_ready` shows namespace in description
    * `Pod_replicas_not_ready` shows namespace in description
    * `Pods_waiting_state` shows namespace in description
    * `Pods_waiting_state_kube-system` shows namespace in description
    * `PVC_low_capacity` shows actual capacity value(%)
    * `RabbitMQ_High_memory(watermark)_usage` shows actual usage value(%) of `Memory high watermark` limit
    * `Redis_missing_master` and `Redis_too_many_masters` show job(instance) name
  * `WarningMetric` alerts:
    * `High_memory_usage` shows actual memory usage value(%)
    * `Redis_disconnected_slaves` shows job(instance) name
    * `PVC_low_capacity` shows actual capacity value(%)
* `grafana`:
  * set `grafana` `resources limits` memory 250Mi -> 500Mi and CPU 0.5 -> 3
  * `grafana-operator` and `crds` update v5.18.0 -> v5.19.4
  * `grafana` update v11.6.0 -> v12.1.1
  * `datasources` `uid` and `name` variables support `tpl`
  * `dashboard services` enabled by default
  * `loki datasources`: timeout increased to 60s
  * `pomerium`
    * increase timeout to 60s
    * enable websockets
* `thanos`:
  * default ingress class is now pomerium
  * image update 0.38.0 -> 0.39.2
* `external-dns` + crds update v0.16.1 -> v0.18.0
* charts update:
  * `prometheus-postgres-exporter` 6.10.0 -> 7.1.1
  * `prometheus-blackbox-exporter` 9.4.0 -> 11.3.1
  * `prometheus-node-exporter` 4.45.0 -> 4.47.3
  * `kube-prometheus-stack` 70.4.1 -> 77.0.2
  * `prometheus-stackdriver-exporter` 4.8.2 -> 4.10.0
  * `external-dns` 8.8.2 -> 9.0.3
  * `thanos` 16.0.4 -> 17.3.1
  * `rabbitmq` 4.4.11 + crds 4.4.6 -> 4.4.34
  * `cert-manager` 1.17.2 + crds 1.17.1 -> 1.17.4
* use `json logs` for default:
  * `argocd`
  * `cert-manager`
  * `rabbitmq-cluster`
  * `external-dns`
  * `gha-operator`
  * `grafana-operator` + `grafana`
  * `konghq ingressController`
  * `postgres-operator` + `pgExporterImage` + `postgres`(inside pod)
  * `redis exporter` + `sentinel exporter`
  * `prometheus`:
    * `prometheus`
    * `node-exporter`
    * `kube-prometheus-stack`
    * `blackbox-exporter`
    * `alertmanager`
    * `stackdriver-exporter`
  * `thanos`:
    * `query`
    * `compactor`
    * `storegateway`

Fixes:
* `prometheus`:
  * `matchers` field used a deprecated syntax (`alertmanager`)
  * alert `Postgres_logical_backup_error` fix `matching labels must be unique on one side`
  * fix relabling `label_app_kubernetes_io_name` -> `container` and linked `inhibitRules` and `alerts`
  * fix alert `Daemonset_not_ready`(did not work)
  * fix sending alerts to tg
* `grafana`: panel `container traffic throughput` rename to `pod traffic throughput`


# 9.6.3

Fixes:
* `thanos`: compactor increase persistent storage size


# 9.6.2

Enhancements:
* `chart_deps/postgres/postgres-cluster`: support for dockerImage attr 

# 9.6.1

Enhancements:
* `gha-runner`: default nodeSelector, tolerations
* `rabbitmq`: update chart 4.4.6 -> 4.4.11
* `external-dns`: update chart 8.7.8 -> 8.8.2
* `cert-manager`: update chart v1.17.1 -> v1.17.2
* `grafana-operator`: update v5.17.1 -> v5.18.0

# 9.6.0

New features:
* `rabbitmq`: ingress to access admin panel
* `argocd,cert-manager,external-dns,gha-operator,grafana,rabbitmq,redis`: resources to chart values
* `gha-runner`:
  * use template to set labels in PodTemplate configmap
  * common attrs to chart values

# 9.5.1

Enhancements:
* Update `spilo` image with
  * `postgresql` version 17.2 -> 17.4
  * `walg` version 3.0.3 -> 3.0.7
  * `patroni` version 4.0.4 -> 4.0.5
  * `pg_profile` version 4.7 -> 4.8

# 9.5.0

New features:
  * `konghq`:
    * move resources to chart values
    * remove affinity rules
    * `kong.enabled` alias
    * move autoscaling to chart values
  * `pomerium`: jwtClaim header for authenticated user email
  * `postgres.pgadmin`:
    * update `pgadmin` to 9.3
    * move all common attrs to chart values
    * enable pomerium auth for it
  * `thanos`:
    * create ingress resources from `chart_deps/app/core` helm lib chart
    * `storegateway,query` ingress resources
    * move common attrs to chart values
    * `thanos app` 0.37.2 -> 0.38.0
    * `thanos chart` 15.14.0 -> 16.0.4

# 9.4.0

New features:
* `pomerium`: move resources to chart values
* `prometheus`:
  * ability to create multiple generic ingress objects
  * all common attributes are moved to chart values

Fixes:
* `chart_deps/app/core`: fix ingress template when multiple ingresses are created

# 9.3.0

New features:
* `postgres`:
  * move operator resources to chart values
  * move logical backup attributes to chart values
  * by default use 17 postgres image
* `environments`: get company domain attrs from `.domain` context var
* `all charts`: new `.Values.global.bucket.type` attribute

# 9.2.0

New features:
 * `grafana/services dashboard`: new Node count pannel
 * `prometheus`: node metrics + node labels metrics

Fixes:
 * `grafana/services dashboard`: fix Redis master/slave pannels when multiple clusters are installed


# 9.1.0
New features:
 * `prometheus`: blackbox `http_3xx` module

Fixes:
 * `argocd`: add ingress names to `app.kubernetes.io/name` label

# 9.0.0

Braking changes:
  * `cert-manager`: interface for creating `ClusterIssuer` obj have changed to using `certificates` chart in `chart_deps`
  * `konghq`: 
    * interface for creating `Issuer` and `Certificate` objs for webhooks have changed to using `certificates` chart in `chart_deps`
    * remove `*` dns record annotations of external dns, this is needed in order to handle properly different ingress controllers
  * `gha-runner-scale-set`:
    * `gha-runner-scale-set-controller` moved to `gha-operator`
    * `gha-runner-scale-set` moved to `gha-runner`
    * delete securityContext from `gha-runner`

New features:
  * `chart_deps/app`: supports ability to turn off global variables (and global secret vars.).

Features:
  * `pomerium`: chart for spinning up pomerium proxy in k8s
  * `chart_deps/app/core`: chart library with templates for rendering core k8s objects (Roles, Services, Ingresses, Jobs etc). Basically it defines a set of `functions` that receive `context` (where .Values, .Release etc obj are) `labels` related obj (service, ingress etc). Based on attributes passed k8s objects are rendered. To use this chart you need to depend on it  in Chart.yaml and use `include` to use its functions
  * `all charts`:
    * new global attr `ingress.class`
    * new admins attribute for`global.company`
  * `argocd`: 
    * added additional ingresses support (using core chart lib) . This is needed because upstream chart doesn't support templates for ingress
    * moved all common configuration to chart `values.yaml`
    * disabled `dex`, `notifications`
    * renamed main chart from `argo-cd` -> `argocd`
  * `grafana`: 
    * added additional ingresses support (using core chart lib) 
    * moved all common configuration to chart `values.yaml`
  * `external-dns`: now handles ingress also
  * `chart_deps/app/common`:
    * adjusted for use of new core library chart. Apps are not affected by this change. Because helm does not yet support recursive dependency updates i have removed `chart_desp/app/common/charts/core-*tgz` out of `.gitignore` and commited it. Without this change helm doesn't see new `defines`.  This PR seems to fix this issue https://github.com/helm/helm/pull/11766. 
    * `deploymentEnabled` parameter that disables/enables deployment
    * `args` attribute to set args
    * annotations can now use templates
  * `chart_deps/security/certificates`:
    * ability to create `ClusterIssuers`
    * ability to create `Issuers`
    * `certs` are now dict
  * subchart and crd updates: 
    * `cert-manager` 1.14.3 -> 1.17.1
    * `gha-operator` 0.9.3 -> 0.11.0
    * `gha-runner` 0.9.3 -> 0.11.0
    * `kong` 2.37.1 -> 2.48.0
    * `external-dns` 6.34.2 -> 8.7.8
    * `argo-cd` 7.4.5 -> 7.8.26
    * `grafana-operator` 5.14.0 -> 5.17.1
    * `grafana app` 10.4.3 -> 11.6.0
    * `rabbitmq-cluster-operator` 3.19.0 -> 4.4.6
    * `thanos` 15.7.25 -> 15.14.0
    * `prometheus`
      * `blackbox-exporter` 9.0.1 -> 9.4.0
      * `node-exporter` 4.41.0 -> 4.45.0
      * `stackdriver-exporter` 4.6.2 -> 4.8.2
      * `kube-state-metrics` 4.2.14 -> 5.0.4
      * `kube-prometheus-stack` 65.5.1 -> 70.4.1
      * `thanos app` 0.36.1 -> 0.37.2
      * `alertmanager app` 0.27.0 -> 0.28.1
      * `prometheus app` 2.54.1 -> 3.2.1
      * `operator crds` 0.77.2 -> 0.81.0
      * `postgres-exporter` 5.3.0 -> 6.10.0

Enchancements:
  * `chart_deps/konghq/plugins`: use templates in plugin names
  * `postgres-exporter` uses prometheus-community helm-charts
  * set default `prometheusSelector "prometheus: main"` in `postgres podMonitor` values

fixes:
  * delete kubeResources.verticalpodautoscalers unsupported variable from `prometheus chart` values
  * fix alert `High_memory_usage` (found duplicate series for the match group on the right hand-side of the operation)
  * fix alert `Pod_replicas_not_ready` (found duplicate series for the match group on the right hand-side of the operation)
  * fix alert `RabbitMQ_High_memory(watermark)_usage` (found duplicate series for the match group on the right hand-side of the operation)
  * fix scripts for updating rabbitmq-cluster-operator and external-dns crds
  * use 'port' instead of `deprecated 'targetPort'` in `postgres podmonitor`

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
