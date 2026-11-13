{{- define "thanos.query.args" -}}
{{- $defaults := deepCopy .Values.common.thanos }}
{{- $overrides := deepCopy (.Values.query.thanos | default dict) }}
{{- $thanos := mustMergeOverwrite $defaults $overrides }}
- query
- --log.level={{ $thanos.logLevel }}
- --log.format={{ $thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if kindIs "string" $thanos.replicaLabel }}
- --query.replica-label={{ $thanos.replicaLabel }}
{{- else }}
{{- range $thanos.replicaLabel }}
- --query.replica-label={{ . }}
{{- end }}
{{- end }}
{{- if kindIs "string" $thanos.stores }}
{{- $stores := tpl $thanos.stores $ | fromYamlArray }}
{{- range $stores }}
- --endpoint={{ . }}
{{- end }}
{{- else }}
{{- range $thanos.stores }}
- --endpoint={{ tpl . $ }}
{{- end }}
{{- end }}
{{- if $thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" $thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
