{{- define "thanos.networkPolicy" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.networkPolicy | default dict) }}
{{- $overrides := deepCopy (.networkPolicy | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- include "core.networkPolicy" (list $root $labels $obj) }}
{{- end }}
