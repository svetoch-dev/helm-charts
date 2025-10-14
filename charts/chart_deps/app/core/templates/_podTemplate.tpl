{{ define "core.podtemplate" }}
{{- $ := index . 0 }}
{{- $obj := index . 1 }}
template:
  metadata:
    {{- with $obj.podAnnotations }}
    annotations:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with $obj.selectorLabels }}
    labels:
    {{- tpl (toYaml .) $ | nindent 6 }}
    {{- end }}
  spec:
    {{- with $obj.imagePullSecrets }}
    imagePullSecrets:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    serviceAccountName: {{ tpl $obj.serviceAccountName $ }}
    {{- if $obj.restartPolicy }}
    restartPolicy: {{ $obj.restartPolicy }}
    {{- end }}
    {{- if $obj.podSecurityContext }}
    securityContext:
    {{- tpl (toYaml $obj.podSecurityContext) $ | nindent 6 }}
    {{- else }}
    securityContext: {}
    {{- end }}
    {{- if $obj.initContainers }}
    initContainers:
    {{- range $name, $container := $obj.initContainers }}
      - name: {{ $container.name }}
        {{- with $container.command }}
        command:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        image: "{{ tpl $container.image $ }}"
        {{- with $container.volumeMounts }}
        volumeMounts:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $container.env }}
        env:
        {{-  tpl (toYaml .) $ | nindent 10}}
        {{- end }}
    {{- end }}
    {{- end }}
    containers:
      - name: {{ $obj.containerName }}
        {{- if $obj.securityContext }}
        securityContext:
        {{- tpl (toYaml $obj.securityContext) $ | nindent 10 }}
        {{- else }}
        securityContext: {}
        {{- end }}
        image: '{{ tpl $obj.image $ }}'
        {{- if $obj.imagePullPolicy }}
        imagePullPolicy: {{ $obj.imagePullPolicy }}
        {{- else }}
        imagePullPolicy: IfNotPresent
        {{- end }}
        {{- with $obj.command }}
        command:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.args }}
        args:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.env }}
        env:
        {{-  tpl (toYaml .) $ | nindent 10}}
        {{- end }}
        {{- with $obj.ports }}
        ports:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.livenessProbe }}
        livenessProbe:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.readinessProbe }}
        readinessProbe:
        {{-  tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.resources }}
        resources:
        {{-  tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
        {{- with $obj.volumeMounts }}
        volumeMounts:
        {{- tpl (toYaml .) $ | nindent 10 }}
        {{- end }}
    {{- with $obj.nodeSelector }}
    nodeSelector:
    {{- tpl (toYaml .) $ | nindent 6 }}
    {{- end }}
    {{- with $obj.affinity }}
    affinity:
    {{- tpl (toYaml .) $ | nindent 6 }}
    {{- end }}
    {{- with $obj.tolerations }}
    tolerations:
    {{- tpl (toYaml .) $ | nindent 6 }}
    {{- end }}
    {{- with $obj.volumes }}
    volumes: 
    {{- tpl (toYaml .) $ | nindent 6 }}
    {{- end }}
{{- end }}
