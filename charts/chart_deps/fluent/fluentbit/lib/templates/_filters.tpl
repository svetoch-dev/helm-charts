{{- define "fluentbit.filter" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "fluentbit.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Filter
metadata:
  labels:
{{- include "fluentbit.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
  namespace: "{{ $obj.namespace }}"
spec:
  {{- with $obj.filters }}
  filters:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.logLevel}}
  logLevel: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.match}}
  match: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.matchRegEx}}
  matchRegEx: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.ordinal}}
  ordinal: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
