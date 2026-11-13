{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/compactor/_pod-template.tpl
Changes: explicit service values, helper names, and list indentation.
*/}}
{{- define "thanos.compactor.args" -}}
{{- $logLevel := .Values.common.thanos.logLevel }}
{{- if hasKey (.Values.compactor.thanos | default dict) "logLevel" }}
{{- $logLevel = .Values.compactor.thanos.logLevel }}
{{- end }}
{{- $logFormat := .Values.common.thanos.logFormat }}
{{- if hasKey (.Values.compactor.thanos | default dict) "logFormat" }}
{{- $logFormat = .Values.compactor.thanos.logFormat }}
{{- end }}
{{- $extraFlags := .Values.common.thanos.extraFlags }}
{{- if hasKey (.Values.compactor.thanos | default dict) "extraFlags" }}
{{- $extraFlags = .Values.compactor.thanos.extraFlags }}
{{- end }}
- compact
- --log.level={{ $logLevel }}
- --log.format={{ $logFormat }}
- --http-address=0.0.0.0:10902
- --data-dir={{ .Values.compactor.thanos.dataDir }}
- --retention.resolution-raw={{ .Values.compactor.thanos.retentionResolutionRaw }}
- --retention.resolution-5m={{ .Values.compactor.thanos.retentionResolution5m }}
- --retention.resolution-1h={{ .Values.compactor.thanos.retentionResolution1h }}
- --consistency-delay={{ .Values.compactor.thanos.consistencyDelay }}
- --compact.concurrency={{ .Values.compactor.thanos.concurrency }}
- --objstore.config-file=/conf/objstore.yml
{{- if $extraFlags }}
{{- include "thanos.args.render" (dict "value" $extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- if not .Values.compactor.thanos.cronJob.enabled }}
- --wait
{{- end }}
{{- end -}}
