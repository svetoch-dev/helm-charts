{{/* Keep the stack prefix independent of the common dependency aliases. */}}
{{- define "thanos-service.prefix" -}}
{{- if contains "thanos" .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-thanos" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
