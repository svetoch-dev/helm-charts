{{- define "thanos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "thanos.fullname" -}}
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

{{- define "thanos.stackFullName" }}
{{- if .serviceKey }}
{{- $settings := get .Values .serviceKey }}
{{- $name := .Values.common.fullnameOverride }}
{{- if hasKey $settings "fullnameOverride" }}
{{- $name = $settings.fullnameOverride }}
{{- end }}
{{- if $name }}
{{- tpl $name . | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" (include "thanos.fullname" .) .component | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- else if .component }}
{{- printf "%s-%s" (include "thanos.fullname" .) .component | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "thanos.fullname" . }}
{{- end }}
{{- end }}

{{- define "thanos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "thanos.labels" -}}
{{- $labels := include "thanos.selectorLabels" . | fromYaml }}
{{- $_ := set $labels "helm.sh/chart" (include "thanos.chart" .) }}
{{- $_ := set $labels "app.kubernetes.io/managed-by" .Release.Service }}
{{- with .Chart.AppVersion }}
{{- $_ := set $labels "app.kubernetes.io/version" . }}
{{- end }}
{{- if .serviceKey }}
{{- $settings := get .Values .serviceKey }}
{{- $defaults := deepCopy (.Values.common.labels | default dict) }}
{{- $overrides := deepCopy ($settings.labels | default dict) }}
{{- $extraLabels := mustMergeOverwrite $defaults $overrides }}
{{- $labels = merge $labels $extraLabels }}
{{- end }}
{{- toYaml $labels }}
{{- end }}

{{- define "thanos.selectorLabels" -}}
{{- $selectors := dict }}
{{- if .serviceKey }}
{{- $settings := get .Values .serviceKey }}
{{- $defaults := deepCopy (.Values.common.selectorLabels | default dict) }}
{{- $overrides := deepCopy ($settings.selectorLabels | default dict) }}
{{- $selectors = mustMergeOverwrite $defaults $overrides }}
{{- end }}
{{- if $selectors }}
{{- tpl (toYaml $selectors) . }}
{{- else }}
app.kubernetes.io/name: {{ include "thanos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}
{{- end }}

{{- define "thanos.namespace" -}}
{{- $namespace := .Values.namespaceOverride | default .Release.Namespace }}
{{- if .serviceKey }}
{{- $settings := get .Values .serviceKey }}
{{- if hasKey .Values.common "namespaceOverride" }}
{{- $namespace = .Values.common.namespaceOverride | default .Release.Namespace }}
{{- end }}
{{- if hasKey $settings "namespaceOverride" }}
{{- $namespace = $settings.namespaceOverride | default .Release.Namespace }}
{{- end }}
{{- end }}
{{- $namespace }}
{{- end }}

{{- define "thanos.component.serviceAccountName" }}
{{- $settings := get .Values .serviceKey }}
{{- $defaults := deepCopy .Values.common.serviceAccount }}
{{- $overrides := deepCopy ($settings.serviceAccount | default dict) }}
{{- $account := mustMergeOverwrite $defaults $overrides }}
{{- if $account.create }}
{{- tpl ($account.name | default (include "thanos.stackFullName" .)) . }}
{{- else }}
{{- tpl ($account.name | default "default") . }}
{{- end }}
{{- end }}

{{- define "thanos.args.render" -}}
{{- $value := .value -}}
{{- if not (kindIs "string" $value) -}}
  {{- $value = toYaml $value -}}
{{- end -}}
{{- tpl $value .context -}}
{{- end -}}
