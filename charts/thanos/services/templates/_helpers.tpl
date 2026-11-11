{{/* Keep the stack prefix independent of the common dependency aliases. */}}
{{- define "thanos.servicePrefix" -}}
{{- if contains "thanos" .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-thanos" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* A YAML argument list lets variable-length stores and alertmanagers use tpl. */}}
{{- define "thanos.serviceArgs" -}}
{{- $component := .Values.containerName -}}
{{- $commands := dict "query" "query" "query-frontend" "query-frontend" "compactor" "compact" "storegateway" "store" "ruler" "rule" "receive" "receive" -}}
{{- $args := list (index $commands $component) (printf "--log.level=%s" .Values.logLevel) (printf "--log.format=%s" .Values.logFormat) -}}
{{- $prefix := include "thanos.servicePrefix" . -}}
{{- $query := printf "%s-query" $prefix -}}
{{- if eq $component "query-frontend" -}}
  {{- $args = concat $args (list "--http-address=0.0.0.0:9090" (printf "--query-frontend.downstream-url=http://%s:9090" $query)) -}}
{{- else if eq $component "compactor" -}}
  {{- $args = concat $args (list "--http-address=0.0.0.0:10902" "--data-dir=/data" (printf "--retention.resolution-raw=%s" .Values.retentionResolutionRaw) (printf "--retention.resolution-5m=%s" .Values.retentionResolution5m) (printf "--retention.resolution-1h=%s" .Values.retentionResolution1h) "--consistency-delay=30m" "--compact.concurrency=1" "--objstore.config-file=/conf/objstore.yml") -}}
{{- else -}}
  {{- $args = concat $args (list "--grpc-address=0.0.0.0:10901" "--http-address=0.0.0.0:10902") -}}
  {{- if eq $component "query" -}}
    {{- $args = append $args (printf "--query.replica-label=%s" .Values.replicaLabel) -}}
    {{- range .Values.stores -}}
      {{- $args = append $args (printf "--endpoint=%s" (tpl . $)) -}}
    {{- end -}}
    {{- $args = append $args (printf "--alert.query-url=http://%s.%s.svc.cluster.local:9090" $query .Release.Namespace) -}}
  {{- else if eq $component "storegateway" -}}
    {{- $args = concat $args (list "--data-dir=/data" "--objstore.config-file=/conf/objstore.yml") -}}
  {{- else if eq $component "ruler" -}}
    {{- $args = concat $args (list "--data-dir=/data" "--eval-interval=1m") -}}
    {{- if not .Values.alertmanagers -}}
      {{- fail "thanos.ruler.alertmanagers is required when ruler is enabled" -}}
    {{- end -}}
    {{- range .Values.alertmanagers -}}
      {{- $args = append $args (printf "--alertmanagers.url=%s" (tpl . $)) -}}
    {{- end -}}
    {{- $args = concat $args (list (printf "--query=dnssrv+_http._tcp.%s.%s.svc.cluster.local" $query .Release.Namespace) (printf "--alert.query-url=http://%s.%s.svc.cluster.local:9090" $query .Release.Namespace) "--label=replica=\"$(POD_NAME)\"" "--label=ruler_cluster=\"\"" "--alert.label-drop=replica" "--objstore.config-file=/conf/objstore/objstore.yml" "--rule-file=/conf/rules/*.yml") -}}
  {{- else if eq $component "receive" -}}
    {{- $args = concat $args (list "--remote-write.address=0.0.0.0:19291" "--receive.capnproto-address=0.0.0.0:19391" "--objstore.config=$(OBJSTORE_CONFIG)" "--tsdb.path=/var/thanos/receive" "--label=replica=\"$(NAME)\"" "--label=receive=\"true\"" (printf "--tsdb.retention=%s" .Values.retention) "--receive.local-endpoint=127.0.0.1:10901" "--receive.hashrings-file=/var/lib/thanos-receive/hashrings.json" "--receive.replication-protocol=capnproto" (printf "--receive.replication-factor=%v" .Values.replicationFactor)) -}}
  {{- end -}}
{{- end -}}
{{- $args = concat $args .Values.extraFlags -}}
{{- if eq $component "compactor" -}}
  {{- $args = append $args "--wait" -}}
{{- end -}}
{{- toYaml $args -}}
{{- end -}}
