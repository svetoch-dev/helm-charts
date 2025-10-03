{{- define "core.serviceMonitor" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $serviceMonitor := index . 2 }}
{{- if $serviceMonitor.prometheusSelector }}
{{- $labels = merge $labels $serviceMonitor.prometheusSelector }}
{{- end }}
{{- if $serviceMonitor.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $serviceMonitor.name $ }}
spec:
  {{- with $serviceMonitor.endpoints }}
  endpoints:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $serviceMonitor.jobLabel }}
  jobLabel: {{ tpl . $ }}
  {{- end }}
  namespaceSelector:
  {{- if eq $serviceMonitor.namespaceSelector "any" }}
    any: true
  {{- else }}
    matchNames:
    - {{ $.Release.Namespace }}
  {{- end }}
  {{- with $serviceMonitor.selectorLabels }}
  selector:
    matchLabels:
    {{- tpl (toYaml .) $ | nindent 6 }}
  {{- end }}
  {{- with $serviceMonitor.targetLabels}}
  targetLabels:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
