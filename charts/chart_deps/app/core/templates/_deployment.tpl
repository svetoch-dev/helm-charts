{{- define "core.deployment" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "core.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $obj.name }}
  labels:
{{- include "core.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  namespace: "{{ $obj.namespace }}"
spec:
  {{- if not $obj.autoscaling.enabled }}
  replicas: {{ $obj.replicaCount }}
  {{- end }}
  {{- if $obj.revisionHistoryLimit  }}
  revisionHistoryLimit: {{ $obj.revisionHistoryLimit }}
  {{- end }}
  selector:
    matchLabels:
      {{- tpl $obj.selectorLabels $ | nindent 6 }}
  {{ include "core.podtemplate" (list $ $obj) | nindent 2 | trim }}
{{- end }}
{{- end }}
