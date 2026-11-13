{{- define "thanos.networkPolicy" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.networkPolicy | default dict) }}
{{- $overrides := deepCopy (.networkPolicy | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- if not (hasKey $obj "namespace") }}
{{- $_ := set $obj "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.networkPolicy" (list $root $labels $obj) }}
{{- end }}
