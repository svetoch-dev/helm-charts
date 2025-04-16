{{- define "core.service" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $service := index . 2 }}
{{- if $service.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ tpl $service.name $ }}
  labels:
{{- $labels | nindent 4 }}
spec:
  type: {{ $service.type }}
  {{- with $service.ports }}
  ports:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $service.externalTrafficPolicy }}
  externalTrafficPolicy: {{ $service.externalTrafficPolicy }}
  {{- end }}
  selector:
    {{- tpl (toYaml $service.selectorLabels) $ | nindent 4 }} 
{{- end }}
{{- end }}

