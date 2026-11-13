{{- define "thanos.service" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy $root.Values.common.service }}
{{- $overrides := deepCopy (.service | default dict) }}
{{- $service := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- if not $service.selectorLabels }}
{{- $_ := set $service "selectorLabels" (include "thanos.selectorLabels" $context | fromYaml) }}
{{- end }}
{{- include "core.service" (list $context $labels $service) }}
{{- end }}
