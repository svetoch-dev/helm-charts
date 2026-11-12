{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted from Bitnami Thanos 17.3.1: templates/query/deployment.yaml
Changes: common.thanos-scoped inputs, helper names, and list indentation.
*/}}
{{- define "thanos.query.args" -}}
- query
- --log.level={{ .Values.thanos.logLevel }}
- --log.format={{ .Values.thanos.logFormat }}
- --grpc-address=0.0.0.0:10901
- --http-address=0.0.0.0:10902
{{- if (include "thanos.args.httpConfigEnabled" .) }}
- --http.config=/conf/http/http-config.yml
{{- end }}
{{- if kindIs "string" .Values.thanos.replicaLabel }}
- --query.replica-label={{ .Values.thanos.replicaLabel }}
{{- else }}
{{- range .Values.thanos.replicaLabel }}
- --query.replica-label={{ . }}
{{- end }}
{{- end }}
{{- if or (include "thanos.args.createSDConfigmap" .) .Values.thanos.existingSDConfigmap }}
- --store.sd-files=/conf/sd/servicediscovery.yml
{{- end }}
{{- if and .Values.thanos.dnsDiscovery.enabled .Values.thanos.dnsDiscovery.sidecarsService .Values.thanos.dnsDiscovery.sidecarsNamespace }}
- --endpoint=dnssrv+_grpc._tcp.{{- include "thanos.args.render" ( dict "value" .Values.thanos.dnsDiscovery.sidecarsService "context" $) -}}.{{- include "thanos.args.render"  ( dict "value" .Values.thanos.dnsDiscovery.sidecarsNamespace "context" $) -}}.svc.{{ .Values.thanos.clusterDomain }}
{{- end }}
{{- if and .Values.thanos.storegateway.enabled .Values.thanos.storegateway.sharded.enabled }}
{{- $shards := int 0 }}
{{- $hashShards := int 1 }}
{{- $timeShards := int 1 }}
{{- if .Values.thanos.storegateway.sharded.hashPartitioning.shards }}
{{- $hashShards = int .Values.thanos.storegateway.sharded.hashPartitioning.shards }}
{{- end }}
{{- if not (empty .Values.thanos.storegateway.sharded.timePartitioning) }}
{{- $timeShards = len .Values.thanos.storegateway.sharded.timePartitioning }}
{{- end }}
{{- $shards = mul $hashShards $timeShards | int }}
{{- range $index, $_ := until $shards }}
{{- if $.Values.thanos.storegateway.useEndpointGroup }}
- --endpoint-group={{ include "thanos-service.prefix" $ }}-storegateway-{{ toString $index }}.{{ $.Release.Namespace }}.svc.{{ $.Values.thanos.clusterDomain }}:{{ $.Values.thanos.storegateway.service.ports.grpc }}
{{- else }}
- --endpoint=dnssrv+_grpc._tcp.{{ include "thanos-service.prefix" $ }}-storegateway-{{ toString $index }}.{{ $.Release.Namespace }}.svc.{{ $.Values.thanos.clusterDomain }}
{{- end }}
{{- end }}
{{- end }}
{{- if and .Values.thanos.storegateway.enabled .Values.thanos.dnsDiscovery.enabled (not .Values.thanos.storegateway.sharded.enabled ) }}
{{- if .Values.thanos.storegateway.useEndpointGroup }}
- --endpoint-group={{ printf "%s-storegateway" (include "thanos-service.prefix" .) }}{{ if .Values.thanos.storegateway.service.additionalHeadless }}-headless{{ end }}.{{ .Release.Namespace }}.svc.{{ .Values.thanos.clusterDomain }}:{{ .Values.thanos.storegateway.service.ports.grpc }}
{{- else }}
- --endpoint=dnssrv+_grpc._tcp.{{ printf "%s-storegateway" (include "thanos-service.prefix" .) }}{{ if .Values.thanos.storegateway.service.additionalHeadless }}-headless{{ end }}.{{ .Release.Namespace }}.svc.{{ .Values.thanos.clusterDomain }}
{{- end }}
{{- end }}
{{- if and .Values.thanos.ruler.enabled .Values.thanos.dnsDiscovery.enabled }}
- --endpoint=dnssrv+_grpc._tcp.{{ printf "%s-ruler" (include "thanos-service.prefix" .) }}{{ if .Values.thanos.ruler.service.additionalHeadless }}-headless{{ end }}.{{ .Release.Namespace }}.svc.{{ .Values.thanos.clusterDomain }}
{{- end }}
{{- if and .Values.thanos.receive.enabled .Values.thanos.dnsDiscovery.enabled }}
- --endpoint=dnssrv+_grpc._tcp.{{ printf "%s-receive" (include "thanos-service.prefix" .) }}{{ if .Values.thanos.receive.service.additionalHeadless }}-headless{{ end }}.{{ .Release.Namespace }}.svc.{{ .Values.thanos.clusterDomain }}
{{- end }}
{{- range .Values.thanos.stores }}
- --endpoint={{ . }}
{{- end }}
{{- if .Values.thanos.grpc.server.tls.enabled }}
- --grpc-server-tls-cert=/certs/server/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-cert") }}
- --grpc-server-tls-key=/certs/server/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "tls-key") }}
{{- if .Values.thanos.grpc.server.tls.clientAuthEnabled }}
- --grpc-server-tls-client-ca=/certs/server/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.server.tls.existingSecret "key" "ca-cert") }}
{{- end }}
{{- end }}
{{- if .Values.thanos.grpc.client.tls.enabled }}
- --grpc-client-tls-secure
- --grpc-client-tls-cert=/certs/client/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.client.tls.existingSecret "key" "tls-cert") }}
- --grpc-client-tls-key=/certs/client/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.client.tls.existingSecret "key" "tls-key") }}
- --grpc-client-tls-ca=/certs/client/{{ include "thanos.args.secretKey" (dict "existingSecret" .Values.thanos.grpc.client.tls.existingSecret "key" "ca-cert") }}
{{- if .Values.thanos.grpc.client.tls.autoGenerated }}
- --grpc-client-tls-skip-verify
{{- end }}
{{- end }}
{{- if .Values.thanos.grpc.client.serverName }}
- --grpc-client-server-name={{ .Values.thanos.grpc.client.serverName }}
{{- end }}
{{- $httpPort := 0 }}
{{- range .Values.service.ports }}
{{- if eq .name "http" }}{{- $httpPort = .port }}{{- end }}
{{- end }}
- --alert.query-url={{ include "thanos.args.queryURL" (dict "context" . "queryURL" .Values.thanos.ruler.queryURL "port" $httpPort) }}
{{- if .Values.thanos.extraFlags }}
{{- include "thanos.args.render" (dict "value" .Values.thanos.extraFlags "context" $) | nindent 0 }}
{{- end }}
{{- end -}}
