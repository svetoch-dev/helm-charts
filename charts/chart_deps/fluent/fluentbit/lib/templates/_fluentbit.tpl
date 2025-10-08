{{- define "fluentbit.fluentbit" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 | fromYaml }}
{{- $fluentbit := index . 2 }}
{{- if eq (hasKey $fluentbit "namespace") false }}
{{- $fluentbit = set $fluentbit "namespace" $.Release.Namespace }}
{{- end }}
{{- if eq (hasKey $fluentbit "enabled") false }}
{{- $fluentbit = set $fluentbit "enabled" true }}
{{- end }}
{{- if $fluentbit.labels }}
{{- $labels = merge $labels $fluentbit.labels }}
{{- end }}
{{- if $.Values.labels }}
{{- $labels = merge $labels $.Values.labels }}
{{- end }}

{{- if $fluentbit.enabled }}
---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: FluentBit
metadata:
  labels:
{{- tpl (toYaml $labels ) $ | nindent 4 }}
  name: {{ tpl $fluentbit.name $ }} 
  namespace: "{{ $fluentbit.namespace }}"
spec:
  {{- with $fluentbit.affinity }}
  affinity:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.annotations }}
  annotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.args }}
  args:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.command }}
  command:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.containerLogRealPath }}
  containerLogRealPath: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.containerSecurityContext }}
  containerSecurityContext:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.disableLogVolumes }}
  disableLogVolumes: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.disableService}}
  disableService: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.dnsPolicy}}
  dnsPolicy: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.envVars }}
  envVars:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.fluentBitConfigName }}
  fluentBitConfigName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.hostAliases }}
  hostAliases:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.hostNetwork }}
  hostNetwork:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.image}}
  image: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.imagePullPolicy }}
  imagePullPolicy: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.imagePullPolicy }}
  imagePullSecrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.initContainers }}
  initContainers:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.internalMountPropagation }}
  internalMountPropagation: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.labels }}
  labels:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.livenessProbe}}
  livenessProbe:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.metricsPort}}
  metricsPort: {{ . }}
  {{- end }}
  {{- with $fluentbit.namespaceFluentBitCfgSelector }}
  namespaceFluentBitCfgSelector:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.nodeSelector }}
  nodeSelector: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.ports}}
  ports:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.positionDB }}
  positionDB:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.priorityClassName }}
  priorityClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.rbacRules }}
  rbacRules:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.readinessProbe }}
  readinessProbe:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.resources }}
  resources:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.runtimeClassName}}
  runtimeClassName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.schedulerName}}
  schedulerName: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $fluentbit.secrets }}
  secrets:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.securityContext }}
  securityContext:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.service }}
  service:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.serviceAccountAnnotations }}
  serviceAccountAnnotations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.tolerations }}
  tolerations:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.volumes }}
  volumes:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
  {{- with $fluentbit.volumesMounts }}
  volumesMounts:
  {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
