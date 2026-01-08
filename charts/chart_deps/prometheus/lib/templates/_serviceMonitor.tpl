{{- define "prometheus.serviceMonitor" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "prometheus.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
  {{- if $obj.prometheusSelector }}
  {{ tpl (toYaml $obj.prometheusSelector) . | nindent 4}}
  {{- end }}
  {{- include "prometheus.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  name: {{ tpl $obj.name $ }}
spec:
  {{- with $obj.endpoints }}
  endpoints:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.jobLabel }}
  jobLabel: {{ tpl . $ }}
  {{- end }}
  namespaceSelector:
  {{- if eq $obj.namespaceSelector "any" }}
    any: true
  {{- else }}
    matchNames:
    - {{ $.Release.Namespace }}
  {{- end }}
  {{- with $obj.selectorLabels }}
  selector:
    matchLabels:
    {{- tpl (toYaml .) $ | nindent 6 }}
  {{- end }}
  {{- with $obj.targetLabels}}
  targetLabels:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
