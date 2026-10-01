{{- define "gha-runner.workflow.podTemplate" -}}
---
apiVersion: v1
kind: PodTemplate
metadata:
  name: {{ .Values.workflowConfigMap.name }}
  {{- with .Values.workflowConfigMap.metaLabels }}
  labels:
    {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with .Values.workflowConfigMap.metaAnnotations }}
  annotations:
    {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- with .Values.workflowConfigMap.spec }}
spec:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gha-runner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gha-runner.labels" -}}
helm.sh/chart: {{ include "gha-runner.chart" . }}
{{ include "gha-runner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "gha-runner.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
