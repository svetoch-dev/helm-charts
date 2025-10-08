{{- define "fluentbit.input" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $input := index . 2 }}
{{- if $input.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Input
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $input.name $ }} 
  namespace: "{{ $input.namespace }}"
spec:
  {{- with $input.alias }}
  alias:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.collectd }}
  collectd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.customPlugin }}
  customPlugin:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.dummy }}
  dummy:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.execWasi }}
  execWasi:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.fluentBitMetrics }}
  fluentBitMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.forward }}
  forward:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.http }}
  http:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.kubernetesEvents }}
  kubernetesEvents:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $input.mqtt }}
  mqtt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.nginx }}
  nginx:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.nodeExporterMetrics }}
  nodeExporterMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.openTelemetry }}
  openTelemetry:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.processors }}
  processors:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.prometheusScrapeMetrics }}
  prometheusScrapeMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.statsd }}
  statsd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.syslog }}
  syslog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.systemd }}
  systemd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.tail }}
  tail:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.tcp }}
  tcp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $input.udp }}
  udp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
