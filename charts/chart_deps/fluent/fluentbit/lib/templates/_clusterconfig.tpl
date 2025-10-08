{{- define "fluentbit.clusterconfig" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $clConfig := index . 2 }}
{{- if eq (hasKey $clConfig "enabled") false }}
{{- $clConfig = set $clConfig "enabled" true }}
{{- end }}
{{- if $clConfig.labels }}
{{- $labels = merge $labels $clConfig.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $clConfig.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterFluentBitConfig
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $clConfig.name $ }} 
spec:
  {{- with $clConfig.configFileFormat }}
  configFileFormat: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $clConfig.filterSelector }}
  filterSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clConfig.inputSelector }}
  inputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clConfig.multilineParserSelector }}
  multilineParserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clConfig.outputSelector }}
  outputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clConfig.parserSelector }}
  parserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $clConfig.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
