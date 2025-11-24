{{- define "fluentbit.secretTemplate" -}}
{{- $ := index . 0 }}
{{- $obj := index . 1 }}
{{- range $name, $parser := $obj.parsers }}
|
  parsers:
  - {{ toYaml $parser | nindent 2 | trim }}
  {{- end }}
  {{- with $obj.service }}
  service:
  {{- tpl (toYaml . ) $ | nindent 2 }}
  {{- end }}
  pipeline:
    {{- if $obj.inputs }}
    inputs:
    {{- range $name, $input := $obj.inputs }}
    - {{ tpl (toYaml $input) $ | nindent 4 | trim }}
    {{- end }}
    {{- end }}
    {{- if $obj.filters }}
    filters:
    {{- range $filter := $obj.filters }}
    - {{ tpl (toYaml $filter) $ | nindent 4 | trim }}
    {{- end }}
    {{- end }}
    {{- if $obj.outputs }}
    outputs:
    {{- range $name, $output := $obj.outputs }}
    {{- if eq $output.name "loki" }}
    {{- $labels := list }}
    {{- range $label_name, $label_value := $output.labels }}
    {{- $labels = append $labels (printf "%s=%s" $label_name $label_value) }}
    {{- end }}
    {{- $output := set $output "labels" (join "," $labels )}}
    {{- end }}
    - {{ tpl (toYaml $output) $ | nindent 4 | trim }}
    {{- end }}
    {{- end }}
{{- end }}
