{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "grafana-operated.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana-operated.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "grafana-operated.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "grafana-operated.labels" -}}
app.kubernetes.io/name: {{ include "grafana-operated.name" . }}
helm.sh/chart: {{ include "grafana-operated.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Grafana container definition. Used when grafana container is not set
*/}}
{{- define "grafana-operated.pod" -}}
{{- $values := mustDeepCopy .Values }}
{{- $values = set $values "containerName" "grafana" }}
{{- $values = set $values "env" .Values.environment }}
{{- $values = set $values "selectorLabels" .Values.labels }}
{{/*
Set mandatory values for core.podtemplate
*/}}
{{- if not .Values.serviceAccountName }}
{{- $values = set $values "serviceAccountName" "remove_me" }}
{{- end }}
{{- $values = set $values "image" "remove_me" }}
{{- $pod_template := include "core.podtemplate" (list . $values) | fromYaml }}
{{/*
By default core.podtemplate sets securityContext to {} if its not set
we need to avoid this in Grafana crd
*/}}
{{- if not .Values.podSecurityContext }}
{{- $_ := unset $pod_template.template.spec "securityContext" }}
{{- end }}
{{- if not .Values.serviceAccountName }}
{{- $_ := unset $pod_template.template.spec "serviceAccountName" }}
{{- end }}
{{- if and (not .Values.podAnnotations) (not .Values.labels) }}
{{- $_ := unset $pod_template.template "metadata" }}
{{- end }}
{{- $container := index $pod_template.template.spec.containers 0 }}
{{/*
We dont need image because we set it via version attribute
*/}}
{{- $_ := unset $container "image" }}
{{- if not .Values.securityContext }}
{{- $_ := unset $container "securityContext" }}
{{- end }}
spec:
{{- toYaml $pod_template | nindent 2 }}
{{- end -}}
