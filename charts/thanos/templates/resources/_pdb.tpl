{{- define "thanos.podDisruptionBudget" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.podDisruptionBudget | default dict) }}
{{- $overrides := deepCopy (.podDisruptionBudget | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- include "core.podDisruptionBudget" (list $root $labels $obj) }}
{{- end }}
