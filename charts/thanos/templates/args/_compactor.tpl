{{- define "thanos.compactor.args" -}}
{{- $defaults := deepCopy .Values.common.thanos }}
{{- $overrides := deepCopy (.Values.compactor.thanos | default dict) }}
{{- $thanos := mustMergeOverwrite $defaults $overrides }}
- compact
- --log.level={{ $thanos.logLevel }}
- --log.format={{ $thanos.logFormat }}
- --http-address=0.0.0.0:10902
- --data-dir={{ $thanos.dataDir }}
- --retention.resolution-raw={{ $thanos.retentionResolutionRaw }}
- --retention.resolution-5m={{ $thanos.retentionResolution5m }}
- --retention.resolution-1h={{ $thanos.retentionResolution1h }}
- --consistency-delay={{ $thanos.consistencyDelay }}
- --compact.concurrency={{ $thanos.concurrency }}
- --objstore.config-file=/conf/objstore.yml
{{- range $thanos.extraFlags }}
- {{ tpl . $ }}
{{- end }}
{{- if not $thanos.cronJob.enabled }}
- --wait
{{- end }}
{{- end -}}
