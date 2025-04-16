{{- define "roles.clusterrole" -}}
{{- $ := index . 0 }}
{{- $labels      := index . 1 }}
{{- $clusterRole := index . 2 }}
{{- if $clusterRole.enabled }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $clusterRole.name $ }} 
rules:
{{- with $clusterRole.rules }}
{{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $clusterRole.name $ }} 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ tpl $clusterRole.name $ }} 
subjects:
- kind: ServiceAccount
  name: {{ tpl $clusterRole.serviceAccount.name $ }}
  namespace: {{ tpl $clusterRole.serviceAccount.namespace $ }}
{{- end -}}
{{- end -}}
