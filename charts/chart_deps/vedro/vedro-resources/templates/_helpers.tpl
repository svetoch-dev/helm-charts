{{- define "vedro-resources.accessName" -}}
{{- $id := printf "%s-%s-%s" .bucket .principal .level | lower -}}
{{- printf "%s-%s" (trimSuffix "-" (trunc 54 $id)) (trunc 8 (sha256sum $id)) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vedro-resources.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vedro-resources.labels" -}}
helm.sh/chart: {{ include "vedro-resources.chart" . }}
app.kubernetes.io/name: {{ .Chart.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
