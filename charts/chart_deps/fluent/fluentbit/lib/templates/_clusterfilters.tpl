{{- define "fluentbit.clusterfilter" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clFilter := index . 2 }}
{{- if eq (hasKey $clFilter "enabled") false }}
{{- $clFilter = set $clFilter "enabled" true }}
{{- end }}
{{- if $clFilter.labels }}
{{- $labels = merge $labels $clFilter.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}
{{- if $clFilter.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterFilter
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clFilter.name $ }} 
spec:
  {{- with $clFilter.filters }}
  filters:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clFilter.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clFilter.match}}
  match: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clFilter.matchRegEx}}
  matchRegEx: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clFilter.ordinal}}
  ordinal: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
