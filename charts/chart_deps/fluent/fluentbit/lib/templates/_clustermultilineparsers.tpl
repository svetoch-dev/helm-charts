{{- define "fluentbit.clustermultilineparsers" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $obj := index . 2 }}
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
kind: ClusterMultilineParser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
spec:
  {{- with $obj.flushTimeout}}
  flushTimeout: {{ . }}
  {{- end }}
  {{- with $obj.keyContent}}
  keyContent: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.parser}}
  parser: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.type}}
  type: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.rules }}
  rules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
