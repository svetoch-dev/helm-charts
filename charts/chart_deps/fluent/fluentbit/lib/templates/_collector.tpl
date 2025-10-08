{{- define "fluentbit.collector" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $collector := index . 2 }}
{{- if eq (hasKey $collector "namespace") false }}
{{- $collector = set $collector "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $collector "enabled") false }}
{{- $collector = set $collector "enabled" true }}
{{- end }}
{{- if $collector.labels }}
{{- $labels = merge $labels $collector.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $collector.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: Collector
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $collector.name $ }} 
  namespace: "{{ $collector.namespace }}"
spec:
  {{- with $collector.affinity }}
  affinity:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.annotations }}
  annotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.args }}
  args:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.bufferPath }}
  bufferPath: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.disableService}}
  disableService: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.fluentBitConfigName }}
  fluentBitConfigName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.hostNetwork }}
  hostNetwork:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.image}}
  image: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.imagePullPolicy }}
  imagePullPolicy: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.imagePullPolicy }}
  imagePullSecrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.nodeSelector }}
  nodeSelector: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.ports}}
  ports:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.priorityClassName }}
  priorityClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.rbacRules }}
  rbacRules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.replicas }}
  replicas: {{ . }}
  {{- end }}
  {{- with $collector.resources }}
  resources:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.runtimeClassName}}
  runtimeClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.schedulerName}}
  schedulerName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $collector.secrets }}
  secrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.securityContext }}
  securityContext:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.serviceAccountAnnotations }}
  serviceAccountAnnotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.tolerations }}
  tolerations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.volumes }}
  volumes:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $collector.volumesMounts }}
  volumesMounts:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
