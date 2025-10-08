{{- define "fluentbit.config" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $config := index . 2 }}
{{- if eq (hasKey $config "namespace") false }}
{{- $config = set $config "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $config "enabled") false }}
{{- $config = set $config "enabled" true }}
{{- end }}
{{- if $config.labels }}
{{- $labels = merge $labels $config.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $config.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: FluentBitConfig
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $config.name $ }} 
  namespace: "{{ $config.namespace }}"
spec:
  {{- with $config.configFileFormat }}
  configFileFormat: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $config.filterSelector }}
  filterSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $config.inputSelector }}
  inputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $config.multilineParserSelector }}
  multilineParserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $config.outputSelector }}
  outputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $config.parserSelector }}
  parserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $config.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
