{{- define "core.pvc" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $pvc := index . 2 }}
{{- if $pvc.enabled }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $pvc.name $ }} 
spec:
  {{- if $pvc.accessModes }}
  accessModes:
  {{- toYaml $pvc.accessModes | nindent 4}}
  {{- else }}
  accessModes:
  - ReadWriteOnce
  {{- end }}
  {{- if $pvc.volumeName }}
  volumeName: {{ tpl $pvc.volumeName $ }}
  {{- end }}
  resources:
    requests:
      storage: {{ $pvc.storage }}
  {{- if $pvc.storageClass }}
  storageClassName: {{ $pvc.storageClass }}
  {{- end }}
{{- end }}
{{- end }}
