{{- define "core.ingress" }}
{{- $ := index . 0 }}
{{- $labels := index . 1 }}
{{- $ingress := index . 2 }}
{{- if $ingress.enabled -}}
{{- $fullName := tpl $ingress.name $ -}}
{{- $svcPort :=  $ingress.service.port -}}
{{- $svcName := tpl $ingress.service.name $ -}}
{{- if and $ingress.className (not (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion)) }}
  {{- if not (hasKey $ingress.annotations "kubernetes.io/ingress.class") }}
  {{- $_ := set $ingress.annotations "kubernetes.io/ingress.class" $ingress.className}}
  {{- end }}
{{- end }}
---
{{- if semverCompare ">=1.19-0" $.Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" $.Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
{{- $labels | nindent 4 }}
  {{- with $ingress.annotations }}
  annotations:
    {{- tpl (toYaml .) $ | nindent 4 }}
  {{- end }}
spec:
  {{- if and $ingress.className (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion) }}
  ingressClassName: {{ tpl $ingress.className $}}
  {{- end }}
  {{- if $ingress.tls }}
  tls:
    {{- range $ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ tpl . $ | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $ingress.hosts }}
    - host: {{ tpl .host $ | quote }}
      {{- $svcPort := or .servicePort $svcPort }}
      {{- $svcName := or .serviceName $svcName }}
      {{- $svcName := tpl $svcName $ }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if and .pathType (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion) }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              {{- if semverCompare ">=1.19-0" $.Capabilities.KubeVersion.GitVersion }}
              service:
                name: {{ $svcName }}
                port:
                  number: {{ $svcPort }}
              {{- else }}
              serviceName: {{ $svcName }}
              servicePort: {{ $svcPort }}
              {{- end }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}
