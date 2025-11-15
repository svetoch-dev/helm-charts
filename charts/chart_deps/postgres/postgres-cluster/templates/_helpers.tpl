{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "postgres-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgres-cluster.fullname" -}}
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
{{- define "postgres-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "postgres-cluster.labels" -}}
app.kubernetes.io/name: {{ include "postgres-cluster.name" . }}
helm.sh/chart: {{ include "postgres-cluster.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Pod Selector labels
*/}}
{{- define "postgres-cluster.podSelectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "postgres-cluster.defaultSidecars" -}}
{{- if .Values.defaultSidecars.enabled }}
{{- range $index, $db := (keys .Values.preparedDatabases | sortAlpha )}}
{{- $dbName := $db | replace "_" "-" }}
{{ $db }}:
  name: "pg-exporter-{{ $dbName }}"
  image: "{{ tpl $.Values.defaultSidecars.pgExporterImage $ }}"
  ports:
    - containerPort: {{ add "9187" $index }}
      name: {{ printf "metrics-%s" $dbName | trunc 15 }}
  resources:
    limits:
      cpu: 200m
      memory: 50Mi
    requests:
      cpu: 10m
      memory: 15Mi
  env:
{{- if eq $index 0 }}
    DATA_SOURCE_NAME:
      value: "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/{{ $db }}?sslmode=disable"
    PG_EXPORTER_COLLECTOR_DATABASE:
      value: "true"
    PG_EXPORTER_COLLECTOR_LOCKS:
      value: "true"
    PG_EXPORTER_COLLECTOR_REPLICATION:
      value: "true"
    PG_EXPORTER_COLLECTOR_REPLICATION_SLOT:
      value: "true"
    PG_EXPORTER_COLLECTOR_STAT_BGWRITER:
      value: "true"
    PG_EXPORTER_COLLECTOR_STAT_DATABASE:
      value: "true"
    PG_EXPORTER_COLLECTOR_STAT_USER_TABLES:
      value: "true"
    PG_EXPORTER_COLLECTOR_STAT_STATEMENTS:
      value: "true"
    PG_EXPORTER_COLLECTOR_STATIO_USER_INDEXES:
      value: "true"
    PG_EXPORTER_COLLECTOR_STATIO_USER_TABLES:
      value: "true"
    PG_EXPORTER_COLLECTOR_WAL:
      value: "true"
    PG_EXPORTER_DISABLE_SETTINGS_METRICS:
      value: "false"
{{- else }}
    PG_EXPORTER_WEB_LISTEN_ADDRESS:
      value: "{{ add "9187" $index }}"
    DATA_SOURCE_NAME:
      value: postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/{{ $db }}?sslmode=disable
    PG_EXPORTER_COLLECTOR_STAT_USER_TABLES:
      value: "true"
    PG_EXPORTER_COLLECTOR_STATIO_USER_INDEXES:
      value: "true"
    PG_EXPORTER_COLLECTOR_STATIO_USER_TABLES:
      value: "true"
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "postgres-cluster.defaultPodMetricsEndpoints" }}
{{- if .Values.defaultSidecars.enabled }}
{{- range $db := (keys .Values.preparedDatabases | sortAlpha )}}
{{- $dbName := $db | replace "_" "-" | trunc 15 }}
{{ $db }}:
  port: {{ printf "metrics-%s" $dbName | trunc 15 }}
  relabelings:
    - sourceLabels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
      action: Replace
      regex: (.*)
      targetLabel: label_app_kubernetes_io_instance
{{- end }}
{{- end }}
{{- end }}

{{- define "postgres-cluster.additionalVolumes" -}}
  {{- if .Values.fluentbit.enabled }}
  {{- with .Values.fluentbit.additionalVolumes }}
  {{- tpl (toYaml .) $ | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- with .Values.additionalVolumes }}
  {{- tpl (toYaml .) $ | nindent 2 }}
  {{- end }}
{{- end }}
