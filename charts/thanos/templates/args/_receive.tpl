{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/receive/statefulset.yaml
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.receive.args" -}}
- receive
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:{{ .Values.thanos.containerPorts.grpc }}
- --http-address=0.0.0.0:{{ .Values.thanos.containerPorts.http }}
- --remote-write.address=0.0.0.0:{{ .Values.thanos.containerPorts.remote }}
- --receive.capnproto-address=0.0.0.0:{{ .Values.thanos.containerPorts.capnproto }}
{{- if or .Values.thanos.objstoreConfig .Values.thanos.existingObjstoreSecret }}
- --objstore.config=$(OBJSTORE_CONFIG)
{{- end }}
{{- if .Values.thanos.tsdbPath }}
- --tsdb.path={{ .Values.thanos.tsdbPath }}
{{- else }}
- --tsdb.path=/var/thanos/receive
{{- end }}
- --label={{ .Values.thanos.replicaLabel }}="$(NAME)"
- --label=receive="true"
- --tsdb.retention={{ .Values.thanos.tsdbRetention }}
{{- if not .Values.thanos.service.additionalHeadless }}
- --receive.local-endpoint=127.0.0.1:{{ .Values.thanos.containerPorts.grpc }}
{{- else }}
- --receive.local-endpoint=$(NAME).{{ printf "%s-receive" (include "thanos-service.prefix" .) }}-headless.$(NAMESPACE).svc.{{ .Values.thanos.clusterDomain }}:{{ .Values.thanos.containerPorts.grpc }}
{{- end }}
{{- if eq .Values.thanos.mode "standalone" }}
- --receive.hashrings-file=/var/lib/thanos-receive/hashrings.json
- --receive.replication-protocol={{ .Values.thanos.replicationProtocol }}
- --receive.replication-factor={{ .Values.thanos.replicationFactor }}
{{- end }}
{{- if .Values.thanos.grpc.server.tls.enabled }}
- --grpc-server-tls-cert=/certs/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-cert") }}
- --grpc-server-tls-key=/certs/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-key") }}
{{- if .Values.thanos.grpc.server.tls.clientAuthEnabled }}
- --grpc-server-tls-client-ca=/certs/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "ca-cert") }}
{{- end }}
{{- end }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
