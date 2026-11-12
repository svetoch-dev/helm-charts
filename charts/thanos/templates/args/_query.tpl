{{- define "thanos.query.args" -}}
- query
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if kindIs "string" .Values.thanos.replicaLabel }}
- --query.replica-label={{ .Values.thanos.replicaLabel }}
{{- else }}
{{- range .Values.thanos.replicaLabel }}
- --query.replica-label={{ . }}
{{- end }}
{{- end }}
{{- if kindIs "string" .Values.thanos.stores }}
{{- $stores := tpl .Values.thanos.stores $ | fromYamlArray }}
{{- range $stores }}
- --endpoint={{ . }}
{{- end }}
{{- else }}
{{- range .Values.thanos.stores }}
- --endpoint={{ tpl . $ }}
{{- end }}
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
