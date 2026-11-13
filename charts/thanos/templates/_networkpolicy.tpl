{{- define "thanos.networkPolicy" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.networkPolicy | default dict) }}
{{- $overrides := deepCopy (.networkPolicy | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $name := include "thanos.stackFullName" $context }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $context | fromYaml) }}
{{- include "core.networkPolicy" (list $context $labels $obj) }}
{{- end }}
