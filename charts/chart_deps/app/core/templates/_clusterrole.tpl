{{- define "core.clusterrole" -}}
{{- $ := index . 0 }}
{{- $labels      := index . 1 }}
{{- $obj := include "core.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- $clusterRoleObj := deepCopy $obj }}
{{- if $obj.clusterRoleLabels }}
{{- $_ := set $clusterRoleObj "labels" (merge (default dict $clusterRoleObj.labels) $obj.clusterRoleLabels) }}
{{- end }}
{{- $clusterRoleBindingObj := deepCopy $obj }}
{{- if $obj.clusterRoleBindingLabels }}
{{- $_ := set $clusterRoleBindingObj "labels" (merge (default dict $clusterRoleBindingObj.labels) $obj.clusterRoleBindingLabels) }}
{{- end }}
{{- if $obj.enabled }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
{{- include "core.labels.constructor" (list $ $labels $clusterRoleObj) | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
rules:
{{- with $obj.rules }}
{{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
{{- include "core.labels.constructor" (list $ $labels $clusterRoleBindingObj) | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ tpl $obj.name $ }} 
subjects:
- kind: ServiceAccount
  name: {{ tpl $obj.serviceAccount.name $ }}
  namespace: {{ tpl (default $.Release.Namespace $obj.serviceAccount.namespace) $ }}
{{- end -}}
{{- end -}}
