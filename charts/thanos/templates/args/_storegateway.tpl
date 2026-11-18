{{- define "thanos.storegateway.args" -}}
{{- $defaults := deepCopy .Values.common.thanos }}
{{- $overrides := deepCopy (.Values.storegateway.thanos | default dict) }}
{{- $thanos := mustMergeOverwrite $defaults $overrides }}
- store
- --log.level={{ $thanos.logLevel }}
- --log.format={{ $thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
- --data-dir=/data
- --objstore.config-file=/conf/objstore.yml
{{- if $thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" $thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
