{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
Adapted helpers from Bitnami Thanos 17.3.1 and Bitnami common.

Shared helpers for the Bitnami 17.3.1 argument definitions. Defines read local
common.thanos values directly. Sibling discovery settings are explicit inputs.
*/}}
{{/* Same tpl behavior as common.tplvalues.render, with common's local context. */}}
{{- define "thanos.args.render" -}}
{{- $value := .value -}}
{{- if not (kindIs "string" $value) -}}
  {{- $value = toYaml $value -}}
{{- end -}}
{{- tpl $value .context -}}
{{- end -}}

{{- define "thanos.args.createSDConfigmap" -}}
{{- if and .Values.thanos.sdConfig (not .Values.thanos.existingSDConfigmap) -}}
true
{{- end -}}
{{- end -}}

{{- define "thanos.args.secretKey" -}}
{{- if and .existingSecret (not (kindIs "string" .existingSecret)) .existingSecret.keyMapping -}}
{{- index .existingSecret.keyMapping .key -}}
{{- else -}}
{{- .key -}}
{{- end -}}
{{- end -}}

{{/* Adapted from Bitnami Thanos 17.3.1, templates/_helpers.tpl (Apache-2.0). */}}
{{- define "thanos.args.queryURL" -}}
{{- $context := .context -}}
{{- $frontend := $context.Values.thanos.queryFrontend -}}
{{- if and $frontend.enabled $frontend.ingress.enabled $frontend.ingress.hostname $frontend.ingress.overrideAlertQueryURL -}}
  {{- printf "%s://%s" (ternary "https" "http" $frontend.ingress.tls) (tpl $frontend.ingress.hostname $context) -}}
{{- else if .queryURL -}}
  {{- tpl .queryURL $context -}}
{{- else -}}
  {{- printf "http://%s-query.%s.svc.%s:%d" (include "thanos-service.prefix" $context) $context.Release.Namespace $context.Values.thanos.clusterDomain (int .port) -}}
{{- end -}}
{{- end -}}
