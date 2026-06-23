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
