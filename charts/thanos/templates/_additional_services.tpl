{{- define "thanos.service.additional" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- range $settings := .additionalServices }}
{{- $service := deepCopy $settings }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- if not $service.selectorLabels }}
{{- $selectorLabels := include "thanos.selectorLabels" $context | fromYaml }}
{{- $service := set $service "selectorLabels" $selectorLabels }}
{{- end }}
{{- include "core.service" (list $context $labels $service )}}
{{- end }}
{{- end }}
