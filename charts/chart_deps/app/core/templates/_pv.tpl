{{- define "core.pv" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $pv := index . 2 }}
{{- if $pv.enabled }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ tpl $pv.name $ }}
spec:
  {{- if $pv.accessModes }}
  accessModes:
  {{- toYaml $pv.accessModes | nindent 4}}
  {{- else }}
  accessModes:
  - ReadWriteOnce
  {{- end }}
  capacity:
    storage: {{ $pv.storage }}
  {{- if $pv.storageClass }}
  storageClassName: {{ $pv.storageClass }}
  {{- end }}
  {{- with $pv.mountOptions }}
  mountOptions:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $pv.csi }}
  csi:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $pv.claimRef }}
  claimRef:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
