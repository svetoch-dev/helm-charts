{{- define "infra.repoURL" -}}
{{- $repo := .Values.global.repo -}}
{{- $repoType := $repo.type -}}
{{- if or (eq $repoType "github") (eq $repoType "gitlab") -}}
{{- $repoType = "git" -}}
{{- end -}}
{{- $repoProvider := $repo.provider -}}
{{- $repoGroup := $repo.group -}}
{{- $repoName := $repo.name -}}
{{- printf "%s@%s:%s/%s.%s" $repoType $repoProvider $repoGroup $repoName $repoType -}}
{{- end -}}
