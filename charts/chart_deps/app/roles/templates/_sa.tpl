{{- define "roles.serviceAccount" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $serviceAccount := index . 2 }}
{{- if $serviceAccount.create }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ tpl $serviceAccount.name $ }}
  labels:
{{- $labels | nindent 4 }}
  {{- with $serviceAccount.annotations }}
  annotations:
    {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
