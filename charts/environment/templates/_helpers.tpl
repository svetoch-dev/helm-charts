{{- define "infra.repoURL" -}}
{{- required "global.repo.url is required" .Values.global.repo.url -}}
{{- end -}}
