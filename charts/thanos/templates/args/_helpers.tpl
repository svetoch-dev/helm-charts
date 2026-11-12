{{- define "thanos.args.render" -}}
{{- $value := .value -}}
{{- if not (kindIs "string" $value) -}}
  {{- $value = toYaml $value -}}
{{- end -}}
{{- tpl $value .context -}}
{{- end -}}
