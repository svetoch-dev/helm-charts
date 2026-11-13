{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/storegateway/statefulset.yaml
Changes: explicit service values, helper names, and list indentation.
*/}}
{{- define "thanos.storegateway.args" -}}
{{- $logLevel := .Values.common.thanos.logLevel }}
{{- if hasKey (.Values.storegateway.thanos | default dict) "logLevel" }}
{{- $logLevel = .Values.storegateway.thanos.logLevel }}
{{- end }}
{{- $logFormat := .Values.common.thanos.logFormat }}
{{- if hasKey (.Values.storegateway.thanos | default dict) "logFormat" }}
{{- $logFormat = .Values.storegateway.thanos.logFormat }}
{{- end }}
{{- $extraFlags := .Values.common.thanos.extraFlags }}
{{- if hasKey (.Values.storegateway.thanos | default dict) "extraFlags" }}
{{- $extraFlags = .Values.storegateway.thanos.extraFlags }}
{{- end }}
- store
- --log.level={{ $logLevel }}
- --log.format={{ $logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
- --data-dir=/data
- --objstore.config-file=/conf/objstore.yml
{{- if $extraFlags }}
{{- include "thanos.args.render" (dict "value" $extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
