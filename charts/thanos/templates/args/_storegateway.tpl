{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/storegateway/statefulset.yaml
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.storegateway.args" -}}
- store
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:{{ .Values.thanos.containerPorts.grpc }}
- --http-address=0.0.0.0:{{ .Values.thanos.containerPorts.http }}
- --data-dir=/data
- --objstore.config-file=/conf/objstore.yml
{{- if .Values.thanos.indexCacheConfig }}
- --index-cache.config-file=/conf/cache/index-cache.yml
{{- end }}
{{- if .Values.thanos.bucketCacheConfig }}
- --store.caching-bucket.config-file=/conf/cache/bucket-cache.yml
{{- end }}
{{- if or .Values.thanos.config .Values.thanos.existingConfigmap }}
- --index-cache.config-file=/conf/cache/config.yml
{{- end }}
{{- if .Values.thanos.grpc.server.tls.enabled }}
- --grpc-server-tls-cert=/certs/grpc/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-cert") }}
- --grpc-server-tls-key=/certs/grpc/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-key") }}
{{- if .Values.thanos.grpc.server.tls.clientAuthEnabled }}
- --grpc-server-tls-client-ca=/certs/grpc/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "ca-cert") }}
{{- end }}
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
