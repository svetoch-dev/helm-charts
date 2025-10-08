{{- define "fluentbit.output" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $output := index . 2 }}
{{- if $output.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Output
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $output.name $ }} 
  namespace: "{{ $output.namespace }}"
spec:
  {{- with $output.matchRegex}}
  matchRegex: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $output.match}}
  match: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $output.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $output.alias }}
  alias:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.azureBlob }}
  azureBlob:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.azureLogAnalytics }}
  azureLogAnalytics:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.cloudWatch }}
  cloudWatch:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.datadog }}
  datadog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.es }}
  es:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.file }}
  file:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.firehouse }}
  firehouse:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.forward }}
  forward:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.gelf }}
  gelf:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.http }}
  http:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.customPlugin }}
  customPlugin:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.influxDB }}
  influxDB:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.kafka }}
  kafka:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.kinesis }}
  kinesis:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.loki }}
  loki:
  {{- $labels := list }}
  {{- range $label_name, $label_value := .labels }}
  {{- $labels = append $labels (printf "%s=%s" $label_name $label_value) }} 
  {{- end }}
  {{- $context := mustDeepCopy . }}
  {{- $context := set $context "labels" $labels }}
  {{- tpl (toYaml $context) $ | nindent 4 }}
  {{- end }}
  {{- with $output.opensearch }}
  opensearch:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.opentelemetry }}
  opentelemetry:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.processors }}
  processors:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.prometheusExporter }}
  prometheusExporter:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.prometheusRemoteWrite }}
  prometheusRemoteWrite:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.s3 }}
  s3:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.splunks }}
  splunks:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.stackdriver }}
  stackdriver:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.stdout }}
  stdout:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.syslog }}
  syslog:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $output.tcp }}
  tcp:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- if (hasKey $output "null") }}
  "null": {}
  {{- end }}
{{- end }}
{{- end }}
