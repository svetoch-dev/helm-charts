{{- define "fluentbit.secret" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := index . 2 }}
{{- $dataStr := include "fluentbit.secretTemplate" (list $ $obj ) | fromYaml }}
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    {{- tpl (toYaml $labels ) $ | nindent 4 }}
  {{- with $obj.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ tpl $obj.name $ }}
  namespace: "{{ $obj.namespace | default $.Release.Namespace }}"
data:
  fluent-bit.yaml: {{ b64enc (tpl $dataStr.secret $) }}
{{- end }}
