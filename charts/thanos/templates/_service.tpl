{{- define "thanos.service" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy $root.Values.common.service }}
{{- $overrides := deepCopy (.service | default dict) }}
{{- $service := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- if not $service.selectorLabels }}
{{- $_ := set $service "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- end }}
{{- if not (hasKey $service "namespace") }}
{{- $_ := set $service "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.service" (list $root $labels $service) }}
{{- end }}
