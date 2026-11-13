{{- define "thanos.query.args" -}}
{{- $logLevel := .Values.common.thanos.logLevel }}
{{- if hasKey (.Values.query.thanos | default dict) "logLevel" }}
{{- $logLevel = .Values.query.thanos.logLevel }}
{{- end }}
{{- $logFormat := .Values.common.thanos.logFormat }}
{{- if hasKey (.Values.query.thanos | default dict) "logFormat" }}
{{- $logFormat = .Values.query.thanos.logFormat }}
{{- end }}
{{- $extraFlags := .Values.common.thanos.extraFlags }}
{{- if hasKey (.Values.query.thanos | default dict) "extraFlags" }}
{{- $extraFlags = .Values.query.thanos.extraFlags }}
{{- end }}
- query
- --log.level={{ $logLevel }}
- --log.format={{ $logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if kindIs "string" .Values.query.thanos.replicaLabel }}
- --query.replica-label={{ .Values.query.thanos.replicaLabel }}
{{- else }}
{{- range .Values.query.thanos.replicaLabel }}
- --query.replica-label={{ . }}
{{- end }}
{{- end }}
{{- if kindIs "string" .Values.query.thanos.stores }}
{{- $stores := tpl .Values.query.thanos.stores $ | fromYamlArray }}
{{- range $stores }}
- --endpoint={{ . }}
{{- end }}
{{- else }}
{{- range .Values.query.thanos.stores }}
- --endpoint={{ tpl . $ }}
{{- end }}
{{- end }}
{{- if $extraFlags }}
{{- include "thanos.args.render" (dict "value" $extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
