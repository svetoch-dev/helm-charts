{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/ruler/statefulset.yaml
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.ruler.args" -}}
{{- if not (or .Values.thanos.alertmanagers .Values.thanos.alertmanagersConfig) -}}
{{- fail "ruler.common.thanos.alertmanagers or ruler.common.thanos.alertmanagersConfig is required when ruler is enabled" -}}
{{- end -}}
{{- if and .Values.thanos.alertmanagers .Values.thanos.alertmanagersConfig -}}
{{- fail "ruler.common.thanos.alertmanagers and ruler.common.thanos.alertmanagersConfig are mutually exclusive" -}}
{{- end -}}
- rule
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:{{ .Values.thanos.containerPorts.grpc }}
- --http-address=0.0.0.0:{{ .Values.thanos.containerPorts.http }}
{{- if .Values.thanos.dataPath }}
- --data-dir={{ .Values.thanos.dataPath }}
{{- else }}
- --data-dir=/data
{{- end }}
- --eval-interval={{ .Values.thanos.evalInterval }}
{{- if (include "thanos.args.httpConfigEnabled" .) }}
- --http.config=/conf/http/http-config.yml
{{- end }}
{{- range .Values.thanos.alertmanagers }}
- --alertmanagers.url={{ . }}
{{- end }}
{{- if .Values.thanos.alertmanagersConfig }}
- --alertmanagers.config-file=/conf/alertmanagers/alertmanagers_config.yml
{{- end }}
{{- if and .Values.thanos.query.enabled .Values.thanos.dnsDiscovery.enabled }}
- --query=dnssrv+_http._tcp.{{ printf "%s-query" (include "thanos-service.prefix" .) }}.{{ .Release.Namespace }}.svc.{{ .Values.thanos.clusterDomain }}
{{- end }}
- --alert.query-url={{ include "thanos.args.queryURL" (dict "context" . "queryURL" .Values.thanos.queryURL "port" .Values.thanos.query.service.ports.http) }}
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
