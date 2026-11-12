{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/compactor/_pod-template.tpl
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.compactor.args" -}}
- compact
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --http-address=0.0.0.0:{{ .Values.thanos.containerPorts.http }}
- --data-dir={{ .Values.thanos.dataDir }}
- --retention.resolution-raw={{ .Values.thanos.retentionResolutionRaw }}
- --retention.resolution-5m={{ .Values.thanos.retentionResolution5m }}
- --retention.resolution-1h={{ .Values.thanos.retentionResolution1h }}
- --consistency-delay={{ .Values.thanos.consistencyDelay }}
- --compact.concurrency={{ .Values.thanos.concurrency }}
- --objstore.config-file=/conf/objstore.yml
{{- if (include "thanos.args.httpConfigEnabled" .) }}
- --http.config=/conf/http/http-config.yml
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- .Values.thanos.extraFlags | toYaml | nindent 0 }}
{{- end }}
{{- if not .Values.thanos.cronJob.enabled }}
- --wait
{{- end }}
{{- end -}}
