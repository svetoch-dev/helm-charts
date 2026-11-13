{{- define "thanos.queryFrontend.args" -}}
{{- $defaults := deepCopy .Values.common.thanos }}
{{- $overrides := deepCopy (.Values.queryFrontend.thanos | default dict) }}
{{- $thanos := mustMergeOverwrite $defaults $overrides }}
- query-frontend
- --log.level={{ $thanos.logLevel }}
- --log.format={{ $thanos.logFormat }}
- --http-address=0.0.0.0:10902
- --query-frontend.downstream-url=http://{{ printf "%s-query" (include "thanos.fullname" .) }}:9090
{{- if $thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" $thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end }}
