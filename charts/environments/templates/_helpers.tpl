{{- define "infra.repoProvider" -}}
{{- $repo := .Values.global.repo -}}
{{- $repoType := required "global.repo.type is required" $repo.type -}}
{{- $repoProvider := $repo.provider -}}
{{- if eq $repoType "github" -}}
{{- $repoProvider = default "github.com" $repoProvider -}}
{{- else if eq $repoType "gitlab" -}}
{{- $repoProvider = default "gitlab.com" $repoProvider -}}
{{- end -}}
{{- required "global.repo.provider is required" $repoProvider -}}
{{- end -}}

{{- define "infra.repoURL" -}}
{{- $repo := .Values.global.repo -}}
{{- $repoProvider := include "infra.repoProvider" . -}}
{{- $repoGroup := required "global.repo.group is required" $repo.group -}}
{{- $repoName := required "global.repo.name is required" $repo.name -}}
{{- printf "git@%s:%s/%s.git" $repoProvider $repoGroup $repoName -}}
{{- end -}}

{{- define "infra.repoRevision" -}}
{{- .Values.global.repo.revision | default "master" -}}
{{- end -}}

{{- define "infra.dnsProvider" -}}
{{- $dnsType := .dns.type | default "" -}}
{{- $dnsProvider := .dns.provider -}}
{{- if eq $dnsType "gcp" -}}
{{- $dnsProvider = default "google" $dnsProvider -}}
{{- else if eq $dnsType "yc" -}}
{{- $dnsProvider = default "webhook" $dnsProvider -}}
{{- else if eq $dnsType "aws" -}}
{{- $dnsProvider = default "aws" $dnsProvider -}}
{{- else if eq $dnsType "cloudflare" -}}
{{- $dnsProvider = default "cloudflare" $dnsProvider -}}
{{- end -}}
{{- $dnsProvider | default "" -}}
{{- end -}}

{{- define "infra.bucketType" -}}
{{- $cloudName := .cloud.name | default "" -}}
{{- $bucketType := "" -}}
{{- with .cloud.buckets -}}
{{- $bucketType = .type | default "" -}}
{{- end -}}
{{- if eq $cloudName "gcp" -}}
{{- $bucketType = default "gcs" $bucketType -}}
{{- else if or (eq $cloudName "yc") (eq $cloudName "aws") -}}
{{- $bucketType = default "s3" $bucketType -}}
{{- end -}}
{{- $bucketType | default "" -}}
{{- end -}}

{{/* Resolve fields in an env that may be templated against that same env. */}}
{{- define "infra.resolveEnv" -}}
{{- $root := .root -}}
{{- $env := deepCopy .env -}}
{{- $_ := set $env "enabled" .enabled -}}
{{- $shortName := $env.short_name -}}
{{- $cloudName := $env.cloud.name -}}
{{- $companyDomain := $root.Values.global.company.domain -}}
{{- $dns := dict -}}
{{- with $env.dns -}}
{{- $dns = deepCopy . -}}
{{- end -}}
{{- $dnsDomainTemplate := $dns.domain | default (printf "%s.%s" $shortName $companyDomain) -}}
{{- $_ := set $dns "domain" $dnsDomainTemplate -}}
{{- $_ = set $dns "provider" (include "infra.dnsProvider" (dict "dns" $dns)) -}}
{{- $cloud := deepCopy $env.cloud -}}
{{- $buckets := dict -}}
{{- with $cloud.buckets -}}
{{- $buckets = deepCopy . -}}
{{- end -}}
{{- $_ = set $buckets "type" (include "infra.bucketType" (dict "cloud" $cloud)) -}}
{{- $_ = set $cloud "buckets" $buckets -}}
{{- $_ = set $env "cloud_short_name" (printf "%s-%s" $cloudName $shortName) -}}
{{- $_ = set $env "dns" $dns -}}
{{- $_ = set $env "cloud" $cloud -}}
{{- $tplContext := deepCopy $root -}}
{{- $_ = set $tplContext.Values.global "env" $env -}}
{{- $_ = set $dns "domain" (tpl $dnsDomainTemplate $tplContext | trimSuffix ".") -}}
{{- $_ = set $env.registry "url" (tpl $env.registry.url $tplContext) -}}
{{- toYaml $env -}}
{{- end -}}
