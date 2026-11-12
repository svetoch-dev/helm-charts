{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/query-frontend/deployment.yaml
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.queryFrontend.args" -}}
- query-frontend
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --http-address=0.0.0.0:{{ .Values.thanos.containerPorts.http }}
- --query-frontend.downstream-url={{ ternary "https" "http" .Values.thanos.https.enabled }}://{{ printf "%s-query" (include "thanos-service.prefix" .) }}:{{ .Values.thanos.query.service.ports.http }}
{{- if or .Values.thanos.config .Values.thanos.existingConfigmap }}
- --query-range.response-cache-config-file=/conf/cache/config.yml
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
