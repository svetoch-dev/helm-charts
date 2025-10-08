{{- define "fluentbit.clusteroutput" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clOutput := index . 2 }}
{{- if eq (hasKey $clOutput "enabled") false }}
{{- $clOutput = set $clOutput "enabled" true }}
{{- end }}
{{- if $clOutput.labels }}
{{- $labels = merge $labels $clOutput.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}
{{- if $clOutput.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterOutput
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clOutput.name $ }} 
spec:
  {{- with $clOutput.matchRegex}}
  matchRegex: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clOutput.match}}
  match: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clOutput.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clOutput.alias }}
  alias:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.azureBlob }}
  azureBlob:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.azureLogAnalytics }}
  azureLogAnalytics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.cloudWatch }}
  cloudWatch:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.datadog }}
  datadog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.es }}
  es:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.file }}
  file:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.firehouse }}
  firehouse:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.forward }}
  forward:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.gelf }}
  gelf:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.http }}
  http:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.customPlugin }}
  customPlugin:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.influxDB }}
  influxDB:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.kafka }}
  kafka:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.kinesis }}
  kinesis:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.loki }}
  loki:
  {{- $labels := list }}
  {{- range $label_name, $label_value := .labels }}
  {{- $labels = append $labels (printf "%s=%s" $label_name $label_value) }} 
  {{- end }}
  {{- $context := mustDeepCopy . }}
  {{- $context := set $context "labels" $labels }}
  {{- tpl (toYaml $context) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.opensearch }}
  opensearch:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.opentelemetry }}
  opentelemetry:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.processors }}
  processors:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.prometheusExporter }}
  prometheusExporter:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.prometheusRemoteWrite }}
  prometheusRemoteWrite:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.s3 }}
  s3:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.splunks }}
  splunks:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.stackdriver }}
  stackdriver:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.stdout }}
  stdout:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.syslog }}
  syslog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clOutput.tcp }}
  tcp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- if (hasKey $clOutput "null") }}
  "null": {}
  {{- end }}
{{- end }}
{{- end }}
