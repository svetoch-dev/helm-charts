{{- define "fluentbit.input" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $obj := index . 2 }}
{{- if eq (hasKey $obj "namespace") false }}
{{- $obj = set $obj "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $obj "enabled") false }}
{{- $obj = set $obj "enabled" true }}
{{- end }}
{{- if $obj.labels }}
{{- $labels = merge $labels $obj.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}
{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Input
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
  namespace: "{{ $obj.namespace }}"
spec:
  {{- with $obj.alias }}
  alias:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.collectd }}
  collectd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.customPlugin }}
  customPlugin:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.dummy }}
  dummy:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.execWasi }}
  execWasi:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.fluentBitMetrics }}
  fluentBitMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.forward }}
  forward:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.http }}
  http:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.kubernetesEvents }}
  kubernetesEvents:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.mqtt }}
  mqtt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.nginx }}
  nginx:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.nodeExporterMetrics }}
  nodeExporterMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.openTelemetry }}
  openTelemetry:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.processors }}
  processors:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.prometheusScrapeMetrics }}
  prometheusScrapeMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.statsd }}
  statsd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.syslog }}
  syslog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.systemd }}
  systemd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.tail }}
  tail:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.tcp }}
  tcp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.udp }}
  udp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
