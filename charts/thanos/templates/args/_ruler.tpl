{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/ruler/statefulset.yaml
Changes: component-scoped thanos inputs, helper names, and list indentation.
*/}}
{{- define "thanos.ruler.args" -}}
{{- if not .Values.thanos.alertmanagers -}}
{{- fail "ruler.thanos.alertmanagers is required when ruler is enabled" -}}
{{- end -}}
- rule
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if .Values.thanos.dataPath }}
- --data-dir={{ .Values.thanos.dataPath }}
{{- else }}
- --data-dir=/data
{{- end }}
- --eval-interval={{ .Values.thanos.evalInterval }}
{{- range .Values.thanos.alertmanagers }}
- --alertmanagers.url={{ . }}
{{- end }}
- --alert.query-url={{ tpl .Values.thanos.queryURL . }}
- --label={{ .Values.thanos.replicaLabel }}="$(POD_NAME)"
- --label=ruler_cluster="{{ .Values.thanos.clusterName }}"
- --alert.label-drop={{ .Values.thanos.replicaLabel }}
- --objstore.config-file=/conf/objstore/objstore.yml
- --rule-file={{ .Values.thanos.ruleFile }}
{{- range .Values.thanos.queries }}
- --query={{ . }}
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
