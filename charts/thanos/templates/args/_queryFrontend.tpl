{{- define "thanos.queryFrontend.args" -}}
{{- $logLevel := .Values.common.thanos.logLevel }}
{{- if hasKey (.Values.queryFrontend.thanos | default dict) "logLevel" }}
{{- $logLevel = .Values.queryFrontend.thanos.logLevel }}
{{- end }}
{{- $logFormat := .Values.common.thanos.logFormat }}
{{- if hasKey (.Values.queryFrontend.thanos | default dict) "logFormat" }}
{{- $logFormat = .Values.queryFrontend.thanos.logFormat }}
{{- end }}
{{- $extraFlags := .Values.common.thanos.extraFlags }}
{{- if hasKey (.Values.queryFrontend.thanos | default dict) "extraFlags" }}
{{- $extraFlags = .Values.queryFrontend.thanos.extraFlags }}
{{- end }}
- query-frontend
- --log.level={{ $logLevel }}
- --log.format={{ $logFormat }}
- --http-address=0.0.0.0:10902
- --query-frontend.downstream-url=http://{{ printf "%s-query" (include "thanos.fullname" .) }}:9090
{{- if $extraFlags }}
{{- include "thanos.args.render" (dict "value" $extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end }}
