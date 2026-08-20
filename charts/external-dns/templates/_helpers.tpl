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
{{- $labels := include "external-dns.labels.base" . | fromYaml -}}
{{- if .Values.commonLabels -}}
{{- $labels = merge $labels .Values.commonLabels -}}
{{- end -}}
{{- toYaml $labels -}}
{{- end -}}

{{- define "external-dns.labels.base" -}}
helm.sh/chart: {{ include "external-dns.chart" . }}
{{ include "external-dns.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "external-dns.podLabels" -}}
{{- $labels := include "external-dns.labels" . | fromYaml -}}
{{- if .Values.deployment.podLabels -}}
{{- $labels = mergeOverwrite $labels .Values.deployment.podLabels -}}
{{- end -}}
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
{{- $repository := .Values.deployment.image.repository -}}
{{- $tag := .Values.deployment.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}

{{- define "external-dns.providerName" -}}
{{- $dns := get (get .Values.global "env" | default dict) "dns" | default dict -}}
{{- $provider := get $dns "provider" -}}
{{- $dnsType := get $dns "type" -}}
{{- if eq $dnsType "gcp" -}}
{{- $provider = default "google" $provider -}}
{{- else if eq $dnsType "yc" -}}
{{- $provider = default "webhook" $provider -}}
{{- else if eq $dnsType "aws" -}}
{{- $provider = default "aws" $provider -}}
{{- else if eq $dnsType "cloudflare" -}}
{{- $provider = default "cloudflare" $provider -}}
{{- end -}}
{{- tpl (toString ($provider | default "")) . -}}
{{- end -}}

{{- define "external-dns.args" -}}
{{- $args := mustDeepCopy .Values.deployment.args -}}
{{- $provider := tpl (toString .Values.provider) . | trim -}}
{{- if $provider -}}
{{- $args = prepend $args (printf "--provider=%s" $provider) -}}
{{- end -}}
{{- if or (eq $provider "aws") (eq $provider "aws-sd") -}}
{{- if .Values.aws.apiRetries -}}{{- $args = append $args (printf "--aws-api-retries=%v" .Values.aws.apiRetries) -}}{{- end -}}
{{- if .Values.aws.zoneType -}}{{- $args = append $args (printf "--aws-zone-type=%v" .Values.aws.zoneType) -}}{{- end -}}
{{- if .Values.aws.assumeRoleArn -}}{{- $args = append $args (printf "--aws-assume-role=%v" .Values.aws.assumeRoleArn) -}}{{- end -}}
{{- if .Values.aws.batchChangeSize -}}{{- $args = append $args (printf "--aws-batch-change-size=%v" .Values.aws.batchChangeSize) -}}{{- end -}}
{{- if .Values.aws.zonesCacheDuration -}}{{- $args = append $args (printf "--aws-zones-cache-duration=%v" .Values.aws.zonesCacheDuration) -}}{{- end -}}
{{- range .Values.aws.zoneTags }}{{- $args = append $args (printf "--aws-zone-tags=%v" .) -}}{{- end -}}
{{- if .Values.aws.preferCNAME -}}{{- $args = append $args "--aws-prefer-cname" -}}{{- end -}}
{{- if .Values.aws.dynamodbTable -}}{{- $args = append $args (printf "--dynamodb-table=%v" .Values.aws.dynamodbTable) -}}{{- end -}}
{{- if .Values.aws.dynamodbRegion -}}{{- $args = append $args (printf "--dynamodb-region=%v" .Values.aws.dynamodbRegion) -}}{{- end -}}
{{- if and (kindIs "bool" .Values.aws.evaluateTargetHealth) (not .Values.aws.evaluateTargetHealth) }}{{- $args = append $args "--no-aws-evaluate-target-health" -}}{{- end -}}
{{- if .Values.aws.zoneMatchParent -}}{{- $args = append $args "--aws-zone-match-parent" -}}{{- end -}}
{{- end -}}
{{- if eq $provider "cloudflare" -}}
{{- if .Values.cloudflare.proxied -}}{{- $args = append $args "--cloudflare-proxied" -}}{{- end -}}
{{- if .Values.cloudflare.dnsRecordsPerPage -}}{{- $args = append $args (printf "--cloudflare-dns-records-per-page=%v" .Values.cloudflare.dnsRecordsPerPage) -}}{{- end -}}
{{- if .Values.cloudflare.regionalServices -}}{{- $args = append $args "--cloudflare-regional-services" -}}{{- end -}}
{{- if .Values.cloudflare.regionKey -}}{{- $args = append $args (printf "--cloudflare-region-key=%v" .Values.cloudflare.regionKey) -}}{{- end -}}
{{- end -}}
{{- if eq $provider "google" -}}
{{- if .Values.google.project -}}{{- $args = append $args (printf "--google-project=%v" .Values.google.project) -}}{{- end -}}
{{- if .Values.google.batchChangeSize -}}{{- $args = append $args (printf "--google-batch-change-size=%v" .Values.google.batchChangeSize) -}}{{- end -}}
{{- if .Values.google.zoneVisibility -}}{{- $args = append $args (printf "--google-zone-visibility=%v" .Values.google.zoneVisibility) -}}{{- end -}}
{{- end -}}
{{- if eq $provider "alibabacloud" -}}
{{- if .Values.alibabacloud.zoneType }}{{- $args = append $args (printf "--alibaba-cloud-zone-type=%v" .Values.alibabacloud.zoneType) -}}{{- end -}}
{{- end -}}
{{- if not (kindIs "map" .Values.extraArgs) -}}
{{- fail "external-dns.extraArgs must be a map" -}}
{{- end -}}
{{- range $key, $value := .Values.extraArgs -}}
{{- if kindIs "invalid" $value -}}
{{- fail (printf "external-dns.extraArgs.%s must not be null; use true for a flag without a value" $key) -}}
{{- else if kindIs "bool" $value -}}
{{- if $value -}}{{- $args = append $args (printf "--%s" $key) -}}{{- end -}}
{{- else if kindIs "slice" $value -}}
{{- range $value -}}{{- $args = append $args (printf "--%s=%s" $key (tpl (toString .) $)) -}}{{- end -}}
{{- else -}}
{{- $args = append $args (printf "--%s=%s" $key (tpl (toString $value) $)) -}}
{{- end -}}
{{- end -}}
{{- toYaml $args -}}
{{- end -}}
