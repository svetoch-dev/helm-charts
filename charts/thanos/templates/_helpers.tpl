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
{{- if .component }}
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
{{- toYaml $labels }}
{{- end }}

{{- define "thanos.selectorLabels" -}}
app.kubernetes.io/name: {{ include "thanos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
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
