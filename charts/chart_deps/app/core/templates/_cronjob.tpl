{{- define "core.cronjob" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $obj := include "core.obj.enricher" (list $ $labels (index . 2)) | fromYaml }}
{{- if $obj.enabled }}
{{- if not $obj.restartPolicy }}
{{- $obj = set $obj "restartPolicy" "OnFailure" }}
{{- end }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ tpl $obj.name $ }}
  namespace: "{{ $obj.namespace }}"
  labels:
{{- include "core.labels.constructor" (list $ $labels $obj) | nindent 4 }}
  {{- with $obj.annotations }}
  annotations:
    {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
spec:
  schedule: {{ tpl (required "core.cronjob requires a schedule" $obj.schedule) $ | quote }}
  {{- with $obj.timeZone }}
  timeZone: {{ tpl . $ | quote }}
  {{- end }}
  {{- with $obj.concurrencyPolicy }}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- if hasKey $obj "startingDeadlineSeconds" }}
  startingDeadlineSeconds: {{ $obj.startingDeadlineSeconds }}
  {{- end }}
  {{- if hasKey $obj "suspend" }}
  suspend: {{ $obj.suspend }}
  {{- end }}
  {{- if hasKey $obj "successfulJobsHistoryLimit" }}
  successfulJobsHistoryLimit: {{ $obj.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if hasKey $obj "failedJobsHistoryLimit" }}
  failedJobsHistoryLimit: {{ $obj.failedJobsHistoryLimit }}
  {{- end }}
  jobTemplate:
    {{- if or $obj.jobLabels $obj.jobAnnotations }}
    metadata:
      {{- with $obj.jobLabels }}
      labels:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $obj.jobAnnotations }}
      annotations:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
    {{- end }}
    spec:
      {{- if hasKey $obj "activeDeadlineSeconds" }}
      activeDeadlineSeconds: {{ $obj.activeDeadlineSeconds }}
      {{- end }}
      {{- if hasKey $obj "backoffLimit" }}
      backoffLimit: {{ $obj.backoffLimit }}
      {{- end }}
      {{- if hasKey $obj "completions" }}
      completions: {{ $obj.completions }}
      {{- end }}
      {{- if hasKey $obj "parallelism" }}
      parallelism: {{ $obj.parallelism }}
      {{- end }}
      {{- if hasKey $obj "ttlSecondsAfterFinished" }}
      ttlSecondsAfterFinished: {{ $obj.ttlSecondsAfterFinished }}
      {{- end }}
      {{ include "core.podtemplate" (list $ $obj) | nindent 6 | trim }}
{{- end }}
{{- end }}
