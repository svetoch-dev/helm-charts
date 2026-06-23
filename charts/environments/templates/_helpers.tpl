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
{{- $envName := .name -}}
{{- $env := deepCopy .env -}}
{{- $shortName := required (printf "global.envs.%s.short_name is required" $envName) $env.short_name -}}
{{- $cloud := required (printf "global.envs.%s.cloud is required" $envName) $env.cloud -}}
{{- $cloudName := required (printf "global.envs.%s.cloud.name is required" $envName) $cloud.name -}}
{{- $kubernetes := required (printf "global.envs.%s.kubernetes is required" $envName) $env.kubernetes -}}
{{- $_ := required (printf "global.envs.%s.kubernetes.server is required" $envName) $kubernetes.server -}}
{{- $companyDomain := required "global.company.domain is required" $root.Values.global.company.domain -}}
{{- $dns := dict -}}
{{- with $env.dns -}}
{{- $dns = deepCopy . -}}
{{- end -}}
{{- $dnsRoot := $dns.root | default $companyDomain -}}
{{- $dnsDomainTemplate := $dns.domain | default (printf "%s.%s" $shortName $companyDomain) -}}
{{- $dnsForTpl := mergeOverwrite (deepCopy $dns) (dict "root" $dnsRoot "domain" $dnsDomainTemplate) -}}
{{- $envForTpl := mergeOverwrite (deepCopy $env) (dict "short_name" $shortName "cloud_short_name" (printf "%s-%s" $cloudName $shortName) "dns" $dnsForTpl) -}}
{{- $tplValues := mergeOverwrite (deepCopy $root.Values) (dict "global" (mergeOverwrite (deepCopy $root.Values.global) (dict "env" $envForTpl))) -}}
{{- $dnsDomain := tpl $dnsDomainTemplate (mergeOverwrite (deepCopy $root) (dict "Values" $tplValues)) | trimSuffix "." -}}
{{- $_ := set $envForTpl "dns" (mergeOverwrite (deepCopy $dns) (dict "root" $dnsRoot "domain" $dnsDomain)) -}}
{{- $tplValues = mergeOverwrite (deepCopy $root.Values) (dict "global" (mergeOverwrite (deepCopy $root.Values.global) (dict "env" $envForTpl))) -}}
{{- $registry := required (printf "global.envs.%s.registry is required" $envName) $env.registry -}}
{{- $registryTemplate := required (printf "global.envs.%s.registry.url is required" $envName) $registry.url -}}
{{- $registryUrl := tpl $registryTemplate (mergeOverwrite (deepCopy $root) (dict "Values" $tplValues)) -}}
{{- $_ = set $envForTpl "registry" (mergeOverwrite (deepCopy $registry) (dict "url" $registryUrl)) -}}
{{- toYaml $envForTpl -}}
{{- end -}}
