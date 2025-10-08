{{- define "fluentbit.clusterparser" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clParser := index . 2 }}
{{- if $clParser.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterParser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clParser.name $ }} 
spec:
  {{- with $clParser.decoders }}
  decoders:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clParser.json }}
  json:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clParser.logFmt }}
  logFmt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clParser.ltsv }}
  ltsv:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clParser.regex }}
  regex:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
