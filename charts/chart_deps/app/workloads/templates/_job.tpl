{{- define "workloads.job" -}}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $job := index . 2 }}
{{- if $job.enabled }}
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
{{- $labels | nindent 4 }}
  name: {{ tpl $job.name $ }}
spec:
  template:
    metadata:
      labels:
        {{- tpl (toYaml $job.selectorLabels) $ | nindent 8 }} 
      name: {{ tpl $job.name $ }}
    spec:
      containers:
      - name: main
        {{- with $job.command }}
        command:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $job.args }}
        args:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $job.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        env:
        {{- with $job.environmentFromSecrets }}
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $job.environment }}
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        image: {{ tpl (printf "%s:%s" $job.image.repository $job.image.tag) $ }}
        imagePullPolicy:  {{ tpl $job.image.pullPolicy $}}
      {{- with $job.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $job.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $job.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      restartPolicy: OnFailure
      {{- with $job.podSecurityContext }}
      securityContext:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ tpl $job.serviceAccount.name $}}
{{- end }}
{{- end }}
