{{- define "fluentbit.clustermultilineparsers" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clMultilineParsers := index . 2 }}
{{- if eq (hasKey $clMultilineParsers "enabled") false }}
{{- $clMultilineParsers = set $clMultilineParsers "enabled" true }}
{{- end }}
{{- if $clMultilineParsers.labels }}
{{- $labels = merge $labels $clMultilineParsers.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $clMultilineParsers.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterMultilineParser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clMultilineParsers.name $ }} 
spec:
  {{- with $clMultilineParsers.flushTimeout}}
  flushTimeout: {{ . }}
  {{- end }}
  {{- with $clMultilineParsers.keyContent}}
  keyContent: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clMultilineParsers.parser}}
  parser: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clMultilineParsers.type}}
  type: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clMultilineParsers.rules }}
  rules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
