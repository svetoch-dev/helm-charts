{{- define "thanos.service.additional" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- range $settings := .additionalServices }}
{{- $service := deepCopy $settings }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- if not $service.selectorLabels }}
{{- $selectorLabels := include "thanos.selectorLabels" $root | fromYaml }}
{{- $service := set $service "selectorLabels" $selectorLabels }}
{{- end }}
{{- if not (hasKey $service "namespace") }}
{{- $_ := set $service "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.service" (list $root $labels $service )}}
{{- end }}
{{- end }}
