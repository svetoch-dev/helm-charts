{{- define "thanos.podDisruptionBudget" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.podDisruptionBudget | default dict) }}
{{- $overrides := deepCopy (.podDisruptionBudget | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $name := include "thanos.stackFullName" $context }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $context | fromYaml) }}
{{- include "core.podDisruptionBudget" (list $context $labels $obj) }}
{{- end }}
