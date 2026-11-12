{{- define "thanos.queryFrontend.args" -}}
- query-frontend
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --http-address=0.0.0.0:10902
- --query-frontend.downstream-url=http://{{ printf "%s-query" (include "thanos-service.prefix" .) }}:9090
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end }}
