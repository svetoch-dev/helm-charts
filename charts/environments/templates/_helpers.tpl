{{- define "infra.repoURL" -}}
{{- $repo := .Values.global.repo -}}
{{- $repoType := required "global.repo.type is required" $repo.type -}}
{{- if or (eq $repoType "github") (eq $repoType "gitlab") -}}
{{- $repoType = "git" -}}
{{- end -}}
{{- $repoProvider := required "global.repo.provider is required" $repo.provider -}}
{{- $repoGroup := required "global.repo.group is required" $repo.group -}}
{{- $repoName := required "global.repo.name is required" $repo.name -}}
{{- printf "%s@%s:%s/%s.%s" $repoType $repoProvider $repoGroup $repoName $repoType -}}
{{- end -}}

{{- define "infra.repoRevision" -}}
{{- required "global.repo.revision is required" .Values.global.repo.revision -}}
{{- end -}}

{{/* Resolve fields in an env that may be templated against that same env. */}}
{{- define "infra.resolveEnv" -}}
{{- $root := .root -}}
{{- $env := deepCopy .env -}}
{{- $shortName := $env.short_name -}}
{{- $cloudName := $env.cloud.name -}}
{{- $companyDomain := $root.Values.global.company.domain -}}
{{- $dns := dict -}}
{{- with $env.dns -}}
{{- $dns = deepCopy . -}}
{{- end -}}
{{- $dnsDomainTemplate := $dns.domain | default (printf "%s.%s" $shortName $companyDomain) -}}
{{- $_ := set $dns "domain" $dnsDomainTemplate -}}
{{- $_ = set $env "cloud_short_name" (printf "%s-%s" $cloudName $shortName) -}}
{{- $_ = set $env "dns" $dns -}}
{{- $tplContext := deepCopy $root -}}
{{- $_ = set $tplContext.Values.global "env" $env -}}
{{- $_ = set $dns "domain" (tpl $dnsDomainTemplate $tplContext | trimSuffix ".") -}}
{{- $_ = set $env.registry "url" (tpl $env.registry.url $tplContext) -}}
{{- toYaml $env -}}
{{- end -}}
