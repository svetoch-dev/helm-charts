{{- define "fluentbit.clusterinput" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clInput := index . 2 }}
{{- if $clInput.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterInput
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clInput.name $ }} 
spec:
  {{- with $clInput.alias }}
  alias:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.collectd }}
  collectd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.customPlugin }}
  customPlugin:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.dummy }}
  dummy:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.execWasi }}
  execWasi:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.fluentBitMetrics }}
  fluentBitMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.forward }}
  forward:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.http }}
  http:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.kubernetesEvents }}
  kubernetesEvents:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clInput.mqtt }}
  mqtt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.nginx }}
  nginx:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.nodeExporterMetrics }}
  nodeExporterMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.openTelemetry }}
  openTelemetry:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.processors }}
  processors:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.prometheusScrapeMetrics }}
  prometheusScrapeMetrics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.statsd }}
  statsd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.syslog }}
  syslog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.systemd }}
  systemd:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.tail }}
  tail:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.tcp }}
  tcp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clInput.udp }}
  udp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
