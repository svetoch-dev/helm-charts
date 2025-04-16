{{- define "roles.role" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $role   := index . 2 }}
{{- if $role.enabled }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $role.name $ }} 
rules:
{{- with $role.rules }}
{{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $role.name $ }} 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ tpl $role.name $ }} 
subjects:
- kind: ServiceAccount
  name: {{ tpl $role.serviceAccount.name $ }}
  namespace: {{ tpl $role.serviceAccount.namespace $ }}
{{- end -}}
{{- end -}}
