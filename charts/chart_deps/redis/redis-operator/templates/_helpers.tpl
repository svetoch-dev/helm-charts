{{/*
Expand the name of the chart.
*/}}
{{- define "redis-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "redis-operator.fullname" -}}
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
{{- define "redis-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "redis-operator.labels" -}}
helm.sh/chart: {{ include "redis-operator.chart" . }}
{{ include "redis-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: operator
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "redis-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Operator image.
*/}}
{{- define "redis-operator.image" -}}
{{- printf "%s:%s" .Values.operator.image (.Values.operator.tag | default (printf "v%s" .Chart.AppVersion)) -}}
{{- end -}}

{{/*
Init container image.
*/}}
{{- define "redis-operator.initContainerImage" -}}
{{- printf "%s:%s" .Values.operator.image (.Values.operator.initContainerImageTag | default .Values.operator.tag | default (printf "v%s" .Chart.AppVersion)) -}}
{{- end -}}

{{/*
Operator feature gates env value.
*/}}
{{- define "redis-operator.featureGates" -}}
{{- $first := true -}}
{{- range $feature, $enabled := .Values.featureGates -}}
{{- if not $first -}},{{- end -}}
{{- $first = false -}}
{{- $feature }}={{ $enabled -}}
{{- end -}}
{{- end -}}

{{/*
Operator container ports.
*/}}
{{- define "redis-operator.ports" -}}
{{- $ports := mustDeepCopy (.Values.operator.ports | default list) }}
{{- if .Values.operator.pprof.enabled }}
{{- $ports = concat $ports (.Values.operator.pprofPorts | default list) }}
{{- end }}
{{- if .Values.webhook.enabled }}
{{- $ports = concat $ports (.Values.operator.webhookPorts | default list) }}
{{- end }}
{{- toYaml $ports }}
{{- end -}}

{{/*
Operator volume mounts.
*/}}
{{- define "redis-operator.volumeMounts" -}}
{{- $volumeMounts := mustDeepCopy (.Values.operator.volumeMounts | default list) }}
{{- if .Values.webhook.enabled }}
{{- $volumeMounts = concat $volumeMounts (.Values.operator.webhookVolumeMounts | default list) }}
{{- end }}
{{- toYaml $volumeMounts }}
{{- end -}}

{{/*
Operator volumes.
*/}}
{{- define "redis-operator.volumes" -}}
{{- $volumes := mustDeepCopy (.Values.operator.volumes | default list) }}
{{- if .Values.webhook.enabled }}
{{- $volumes = concat $volumes (.Values.operator.webhookVolumes | default list) }}
{{- end }}
{{- toYaml $volumes }}
{{- end -}}
