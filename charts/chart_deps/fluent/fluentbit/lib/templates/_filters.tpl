{{- define "fluentbit.filter" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $filter := index . 2 }}
{{- if $filter.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Filter
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $filter.name $ }} 
  namespace: "{{ $filter.namespace }}"
spec:
  {{- with $filter.filters }}
  filters:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $filter.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $filter.match}}
  match: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $filter.matchRegEx}}
  matchRegEx: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $filter.ordinal}}
  ordinal: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
