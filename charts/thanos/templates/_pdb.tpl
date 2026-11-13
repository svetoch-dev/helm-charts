{{- define "thanos.podDisruptionBudget" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.podDisruptionBudget | default dict) }}
{{- $overrides := deepCopy (.podDisruptionBudget | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- if not (hasKey $obj "namespace") }}
{{- $_ := set $obj "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.podDisruptionBudget" (list $root $labels $obj) }}
{{- end }}
