{{- define "fluentbit.multilineparser" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $multilineParser := index . 2 }}
{{- if $multilineParser.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: MultilineParser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $multilineParser.name $ }} 
  namespace: "{{ $multilineParser.namespace }}"
spec:
  {{- with $multilineParser.flushTimeout}}
  flushTimeout: {{ . }}
  {{- end }}
  {{- with $multilineParser.keyContent}}
  keyContent: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $multilineParser.parser}}
  parser: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $multilineParser.type}}
  type: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $multilineParser.rules }}
  rules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
