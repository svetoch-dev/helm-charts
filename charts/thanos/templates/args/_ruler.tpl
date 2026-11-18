{{- define "thanos.ruler.args" -}}
{{- $defaults := deepCopy .Values.common.thanos }}
{{- $overrides := deepCopy (.Values.ruler.thanos | default dict) }}
{{- $thanos := mustMergeOverwrite $defaults $overrides }}
{{- if not $thanos.alertmanagers -}}
{{- fail "ruler.thanos.alertmanagers is required when ruler is enabled" -}}
{{- end -}}
- rule
- --log.level={{ $thanos.logLevel }}
- --log.format={{ $thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if $thanos.dataPath }}
- --data-dir={{ $thanos.dataPath }}
{{- else }}
- --data-dir=/data
{{- end }}
- --eval-interval={{ $thanos.evalInterval }}
{{- range $thanos.alertmanagers }}
- --alertmanagers.url={{ . }}
{{- end }}
- --alert.query-url={{ tpl $thanos.queryURL . }}
- --label={{ $thanos.replicaLabel }}="$(POD_NAME)"
- --label=ruler_cluster="{{ $thanos.clusterName }}"
- --alert.label-drop={{ $thanos.replicaLabel }}
- --objstore.config-file=/conf/objstore/objstore.yml
- --rule-file={{ $thanos.ruleFile }}
{{- range $thanos.queries }}
- --query={{ . }}
{{- end }}
{{- range $thanos.extraFlags }}
- {{ tpl . $ }}
{{- end }}
{{- end -}}
