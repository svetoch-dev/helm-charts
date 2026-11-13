{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/storegateway/statefulset.yaml
Changes: component-scoped thanos inputs, helper names, and list indentation.
*/}}
{{- define "thanos.storegateway.args" -}}
- store
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
- --data-dir=/data
- --objstore.config-file=/conf/objstore.yml
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
