{{/*
NOTE: these helpers are intentionally prefixed with "gitlabwrapper" instead of
"gitlab". The vendored upstream dependency (charts/gitlab-10.1.1.tgz) is
ITSELF a chart named "gitlab" and defines its own internal helpers named
"gitlab.name", "gitlab.selectorLabels", "gitlab.labels", etc. (see its
templates/_application.tpl). Helm's named-template namespace is global across
a chart and all its subcharts - if this wrapper defined templates with the
same names, it would silently shadow/override the vendored chart's own
helpers everywhere they're used internally (e.g. inside
webservice/templates/deployment.yaml), breaking the selector/pod-template
label consistency that Deployment/StatefulSet objects require. This caused a
real "spec.template.metadata.labels: ... `selector` does not match template
`labels`" apply error on the webservice Deployment. Do NOT rename these back
to a "gitlab.*" prefix.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "gitlabwrapper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitlabwrapper.fullname" -}}
{{- if .Values.fullnameOverride }}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gitlabwrapper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gitlabwrapper.labels" -}}
helm.sh/chart: {{ include "gitlabwrapper.chart" . }}
{{ include "gitlabwrapper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gitlabwrapper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gitlabwrapper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
