{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/compactor/_pod-template.tpl
Changes: explicit service values, helper names, and list indentation.
*/}}
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
{{- if $thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" $thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- if not $thanos.cronJob.enabled }}
- --wait
{{- end }}
{{- end -}}
