{{- define "thanos.serviceMonitor" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.serviceMonitor | default dict) }}
{{- $overrides := deepCopy (.serviceMonitor | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $selectors := include "thanos.selectorLabels" $root | fromYaml }}
{{- $monitorSelectors := deepCopy ($obj.selectorLabels | default dict) }}
{{- $_ := set $obj "selectorLabels" (mustMergeOverwrite $selectors $monitorSelectors) }}
{{- if not (hasKey $obj "namespace") }}
{{- $_ := set $obj "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "prometheus.serviceMonitor" (list $root $labels $obj) }}
{{- end }}
