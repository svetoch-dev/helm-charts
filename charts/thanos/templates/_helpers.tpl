{{/*
Expand the name of the chart.
*/}}
{{- define "thanos.name" -}}
{{- default .Chart.Name (.stackName | default .Values.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "thanos.fullname" -}}
{{- if .stackFullname }}
{{- .stackFullname }}
{{- else if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "thanos.stackFullName" }}
{{- if .componentFullname }}
{{- .componentFullname }}
{{- else if .component }}
{{- printf "%s-%s" (include "thanos.fullname" .) .component }}
{{- else }}
{{- include "thanos.fullname" . }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "thanos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "thanos.labels" -}}
helm.sh/chart: {{ include "thanos.chart" . }}
{{ include "thanos.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "thanos.selectorLabels" -}}
{{- if and .stackFullname .Values.selectorLabels }}
{{- tpl (toYaml .Values.selectorLabels) . }}
{{- else }}
app.kubernetes.io/name: {{ include "thanos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}
{{- end }}


{{- define "thanos.args.render" -}}
{{- $value := .value -}}
{{- if not (kindIs "string" $value) -}}
  {{- $value = toYaml $value -}}
{{- end -}}
{{- tpl $value .context -}}
{{- end -}}
