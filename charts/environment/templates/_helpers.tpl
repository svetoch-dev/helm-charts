{{- define "infra.repoURL" -}}
{{- $repo := .Values.global.repo -}}
{{- $repoType := required "global.repo.type is required" $repo.type -}}
{{- $repoProvider := required "global.repo.provider is required" $repo.provider -}}
{{- $repoGroup := required "global.repo.group is required" $repo.group -}}
{{- $repoName := required "global.repo.name is required" $repo.name -}}
{{- printf "%s@%s:%s/%s.%s" $repoType $repoProvider $repoGroup $repoName $repoType -}}
{{- end -}}

{{- define "infra.repoRevision" -}}
{{- required "global.repo.revision is required" .Values.global.repo.revision -}}
{{- end -}}
