{{- define "thanos.service" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy $root.Values.common.service }}
{{- $overrides := deepCopy (.service | default dict) }}
{{- $service := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- if not $service.selectorLabels }}
{{- $_ := set $service "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- end }}
{{- include "core.service" (list $root $labels $service) }}
{{- end }}
