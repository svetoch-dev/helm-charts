{{- define "external-dns.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "external-dns.fullname" -}}
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

{{- define "external-dns.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "external-dns.selectorLabels" -}}
app.kubernetes.io/name: {{ include "external-dns.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "external-dns.labels" -}}
helm.sh/chart: {{ include "external-dns.chart" . }}
{{ include "external-dns.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "external-dns.podLabels" -}}
{{- $labels := include "external-dns.labels" . | fromYaml -}}
{{- $_ := unset $labels "app.kubernetes.io/instance" -}}
{{- $_ = unset $labels "app.kubernetes.io/name" -}}
{{- toYaml $labels -}}
{{- end -}}

{{- define "external-dns.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "external-dns.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- required "external-dns.serviceAccount.name is required when serviceAccount.create is false" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "external-dns.image" -}}
{{- $repository := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}

{{- define "external-dns.providerName" -}}
{{- $global := .Values.global | default dict -}}
{{- $env := $global.env | default dict -}}
{{- $dns := $env.dns | default dict -}}
{{- $provider := $dns.provider | default "" -}}
{{- $dnsType := $dns.type | default "" -}}
{{- if eq $dnsType "gcp" -}}
{{- $provider = default "google" $provider -}}
{{- else if eq $dnsType "yc" -}}
{{- $provider = default "webhook" $provider -}}
{{- else if eq $dnsType "aws" -}}
{{- $provider = default "aws" $provider -}}
{{- else if eq $dnsType "cloudflare" -}}
{{- $provider = default "cloudflare" $provider -}}
{{- end -}}
{{- if not $provider -}}
{{- $configured := .Values.provider -}}
{{- if kindIs "map" $configured -}}
{{- $provider = $configured.name | default "" -}}
{{- else -}}
{{- $provider = $configured | default "" -}}
{{- end -}}
{{- end -}}
{{- tpl (toString $provider) . -}}
{{- end -}}
