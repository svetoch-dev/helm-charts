{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fluentbit-parsers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fluentbit-parsers.fullname" -}}
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
{{- define "fluentbit-parsers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fluentbit-parsers.labels" -}}
app.kubernetes.io/name: {{ include "fluentbit-parsers.name" . }}
helm.sh/chart: {{ include "fluentbit-parsers.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Service Selector labels
*/}}
{{- define "fluentbit-parsers.serviceSelectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}-{{ include "fluentbit-parsers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "fluentbit-parsers.redisExporterDefaults" -}}
{{- if .Values.redis.exporter.enabled }}
image: oliver006/redis_exporter:v1.73.0@sha256:1a8f5e48b2af0fb02d182be3ddd623e7e39881b6464bdb5bf843b1f6d45ed050
resources:
  requests:
    cpu: 10m
    memory: 15Mi
  limits:
    cpu: 100m
    memory: 50Mi
{{- if .Values.auth.secretPath }}
env:
- name: REDIS_USER
  value: default
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      key: password
      name: {{ .Values.auth.secretPath }}
{{- end }}
{{- end }}
{{- end }}

{{- define "sentinel-operated.sentinelExporterDefaults" -}}
{{- if .Values.sentinel.exporter.enabled }}
image: leominov/redis_sentinel_exporter:1.7.1@sha256:812e617d2201d0ee8ba51d60b9fe9590a46bed84abc95746f554e1ca04e5478a
resources:
  requests:
    cpu: 10m
    memory: 15Mi
  limits:
    cpu: 100m
    memory: 50Mi
{{- end }}
{{- end }}
