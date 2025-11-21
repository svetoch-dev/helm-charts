{{- define "fluentbit.secret" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "fluentbit.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: v1
kind: Secret
metadata:
  labels:
{{- include "fluentbit.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  {{- with $obj.annotations }}
  annotations:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ tpl $obj.name $ }}
  namespace: "{{ $obj.namespace }}"
type: {{ $obj.type }}
data:
{{- range $dataKey, $dataStr := $obj.data }}
  {{- if $dataStr }}
  {{ $dataKey }}: {{ b64enc (tpl $dataStr $) }}
  {{- else }}
  {{ $dataKey }}: ""
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
