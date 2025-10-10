{{- define "fluentbit.clusterconfig" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "fluentbit.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterFluentBitConfig
metadata:
  labels:
{{- include "fluentbit.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
spec:
  {{- with $obj.configFileFormat }}
  configFileFormat: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.filterSelector }}
  filterSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.inputSelector }}
  inputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.multilineParserSelector }}
  multilineParserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.outputSelector }}
  outputSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.parserSelector }}
  parserSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
