{{ define "core.podtemplate" }}
{{- $ := index . 0 }}
{{- $obj := index . 1 }}
template:
   metadata:
     {{- with $obj.podAnnotations }}
     annotations:
       {{- toYaml . | nindent 8 }}
     {{- end }}
     labels:
       {{- tpl $obj.selectorLabels $ | nindent 8 }}
   spec:
     {{- with $obj.imagePullSecrets }}
     imagePullSecrets:
       {{- toYaml . | nindent 8 }}
     {{- end }}
     serviceAccountName: {{ tpl $obj.serviceAccountName $ }}
     securityContext:
       {{- toYaml $obj.podSecurityContext | nindent 8 }}
     {{- if $obj.initContainers }}
     initContainers:
     {{- range $name, $container := $obj.initContainers }}
       - name: {{ $container.name }}
         {{- with $container.command }}
         command:
           {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         image: "{{ tpl $container.image $ }}"
         {{- with $container.volumeMounts }}
         volumeMounts:
         {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $container.env }}
         env:
         {{-  tpl (toYaml .) $ | nindent 12}}
         {{- end }}
     {{- end }}
     {{- end }}
     containers:
       - name: {{ $obj.containerName }}
         securityContext:
           {{- toYaml $obj.securityContext | nindent 12 }}
         image: '{{ tpl $obj.image $ }}'
         imagePullPolicy: {{ $obj.imagePullPolicy }}
         {{- with $obj.command }}
         command:
           {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.args }}
         args:
           {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.env }}
         env:
         {{-  tpl (toYaml .) $ | nindent 12}}
         {{- end }}
         {{- with $obj.ports }}
         ports:
           {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.livenessProbe }}
         livenessProbe:
           {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.readinessProbe }}
         readinessProbe:
           {{-  tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.resources }}
         resources:
           {{-  tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
         {{- with $obj.volumeMounts }}
         volumeMounts:
         {{- tpl (toYaml .) $ | nindent 12 }}
         {{- end }}
     {{- with $obj.nodeSelector }}
     nodeSelector:
       {{- tpl (toYaml .) $ | nindent 8 }}
     {{- end }}
     {{- with $obj.affinity }}
     affinity:
       {{- tpl (toYaml .) $ | nindent 8 }}
     {{- end }}
     {{- with $obj.tolerations }}
     tolerations:
       {{- tpl (toYaml .) $ | nindent 8 }}
     {{- end }}
     {{- with $obj.volumes }}
     volumes: 
       {{- tpl (toYaml .) $ | nindent 8 }}
     {{- end }}
{{- end }}
