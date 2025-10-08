{{- define "fluentbit.parser" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $parser := index . 2 }}
{{- if $parser.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Parser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $parser.name $ }} 
  namespace: "{{ $parser.namespace }}"
spec:
  {{- with $parser.decoders }}
  decoders:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $parser.json }}
  json:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $parser.logFmt }}
  logFmt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $parser.ltsv }}
  ltsv:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $parser.regex }}
  regex:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
