{{- define "fluentbit.parser" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $obj := index . 2 }}
{{- if eq (hasKey $obj "namespace") false }}
{{- $obj = set $obj "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $obj "enabled") false }}
{{- $obj = set $obj "enabled" true }}
{{- end }}
{{- if $obj.labels }}
{{- $labels = merge $labels $obj.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Parser
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
  namespace: "{{ $obj.namespace }}"
spec:
  {{- with $obj.decoders }}
  decoders:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.json }}
  json:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.logFmt }}
  logFmt:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.ltsv }}
  ltsv:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.regex }}
  regex:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
