{{- define "fluentbit.clustermultilineparsers" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "fluentbit.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterMultilineParser
metadata:
  labels:
{{- include "fluentbit.labels.constructor" (list $ $labels $obj) | nindent 4 }}
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
