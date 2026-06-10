{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redis-operated.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis-operated.fullname" -}}
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
Redis replication resource name.
*/}}
{{- define "redis-operated.clusterName" -}}
{{- printf "%s-cluster" (include "redis-operated.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Redis sentinel resource name.
*/}}
{{- define "redis-operated.sentinelName" -}}
{{- printf "%s-sentinel" (include "redis-operated.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redis-operated.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "redis-operated.labels" -}}
helm.sh/chart: {{ include "redis-operated.chart" . }}
{{ include "redis-operated.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: middleware
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "redis-operated.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-operated.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Validate service type and return the value. */}}
{{- define "redis-operated.validateServiceType" -}}
{{- $allowedServiceTypes := list "ClusterIP" "NodePort" "LoadBalancer" -}}
{{- $serviceType := .serviceType | default "ClusterIP" -}}
{{- if has $serviceType $allowedServiceTypes -}}
{{- $serviceType -}}
{{- else -}}
{{- fail (printf "%s serviceType must be one of ClusterIP, NodePort, LoadBalancer; got: %s" .name $serviceType) -}}
{{- end -}}
{{- end -}}

{{/* Generate init container properties */}}
{{- define "initContainer.properties" -}}
{{- with .Values.initContainer }}
{{- if .enabled }}
enabled: {{ .enabled }}
image: {{ .image }}
{{- if .imagePullPolicy }}
imagePullPolicy: {{ .imagePullPolicy }}
{{- end }}
{{- if .resources }}
resources:
  {{ toYaml .resources | nindent 2 }}
{{- end }}
{{- if .env }}
env:
{{ toYaml .env | nindent 2 }}
{{- end }}
{{- if .command }}
command:
{{ toYaml .command | nindent 2 }}
{{- end }}
{{- if .args }}
args:
{{ toYaml .args | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
