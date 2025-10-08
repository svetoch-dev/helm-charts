{{- define "fluentbit.fluentbit" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $obj := index . 2 }}
{{- if eq (hasKey $obj "namespace") false }}
{{- $obj = set $obj "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $obj "enabled") false }}
{{- $obj = set $obj "enabled" true }}
{{- end }}
{{- if $obj.labels }}
{{- $labels = merge $labels $obj.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $obj.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: FluentBit
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $obj.name $ }} 
  namespace: "{{ $obj.namespace }}"
spec:
  {{- with $obj.affinity }}
  affinity:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.annotations }}
  annotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.args }}
  args:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.command }}
  command:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.containerLogRealPath }}
  containerLogRealPath: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.containerSecurityContext }}
  containerSecurityContext:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.disableLogVolumes }}
  disableLogVolumes: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.disableService}}
  disableService: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.dnsPolicy}}
  dnsPolicy: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.envVars }}
  envVars:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.fluentBitConfigName }}
  fluentBitConfigName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.hostAliases }}
  hostAliases:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.hostNetwork }}
  hostNetwork:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.image}}
  image: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.imagePullPolicy }}
  imagePullPolicy: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.imagePullPolicy }}
  imagePullSecrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.initContainers }}
  initContainers:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.internalMountPropagation }}
  internalMountPropagation: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.labels }}
  labels:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.livenessProbe}}
  livenessProbe:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.metricsPort}}
  metricsPort: {{ . }}
  {{- end }}
  {{- with $obj.namespaceFluentBitCfgSelector }}
  namespaceFluentBitCfgSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.nodeSelector }}
  nodeSelector: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.ports}}
  ports:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.positionDB }}
  positionDB:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.priorityClassName }}
  priorityClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.rbacRules }}
  rbacRules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.readinessProbe }}
  readinessProbe:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.resources }}
  resources:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.runtimeClassName}}
  runtimeClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.schedulerName}}
  schedulerName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.secrets }}
  secrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.securityContext }}
  securityContext:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.serviceAccountAnnotations }}
  serviceAccountAnnotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.tolerations }}
  tolerations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.volumes }}
  volumes:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $obj.volumesMounts }}
  volumesMounts:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
