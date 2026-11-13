{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/ruler/statefulset.yaml
Changes: explicit service values, helper names, and list indentation.
*/}}
{{- define "thanos.ruler.args" -}}
{{- $logLevel := .Values.common.thanos.logLevel }}
{{- if hasKey (.Values.ruler.thanos | default dict) "logLevel" }}
{{- $logLevel = .Values.ruler.thanos.logLevel }}
{{- end }}
{{- $logFormat := .Values.common.thanos.logFormat }}
{{- if hasKey (.Values.ruler.thanos | default dict) "logFormat" }}
{{- $logFormat = .Values.ruler.thanos.logFormat }}
{{- end }}
{{- $extraFlags := .Values.common.thanos.extraFlags }}
{{- if hasKey (.Values.ruler.thanos | default dict) "extraFlags" }}
{{- $extraFlags = .Values.ruler.thanos.extraFlags }}
{{- end }}
{{- if not .Values.ruler.thanos.alertmanagers -}}
{{- fail "ruler.thanos.alertmanagers is required when ruler is enabled" -}}
{{- end -}}
- rule
- --log.level={{ $logLevel }}
- --log.format={{ $logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if .Values.ruler.thanos.dataPath }}
- --data-dir={{ .Values.ruler.thanos.dataPath }}
{{- else }}
- --data-dir=/data
{{- end }}
- --eval-interval={{ .Values.ruler.thanos.evalInterval }}
{{- range .Values.ruler.thanos.alertmanagers }}
- --alertmanagers.url={{ . }}
{{- end }}
- --alert.query-url={{ tpl .Values.ruler.thanos.queryURL . }}
- --label={{ .Values.ruler.thanos.replicaLabel }}="$(POD_NAME)"
- --label=ruler_cluster="{{ .Values.ruler.thanos.clusterName }}"
- --alert.label-drop={{ .Values.ruler.thanos.replicaLabel }}
- --objstore.config-file=/conf/objstore/objstore.yml
- --rule-file={{ .Values.ruler.thanos.ruleFile }}
{{- range .Values.ruler.thanos.queries }}
- --query={{ . }}
{{- end }}
{{- if $extraFlags }}
{{- include "thanos.args.render" (dict "value" $extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
