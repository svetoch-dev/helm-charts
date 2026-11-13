{{- define "thanos.serviceMonitor" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.serviceMonitor | default dict) }}
{{- $overrides := deepCopy (.serviceMonitor | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $name := include "thanos.stackFullName" $context }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $selectors := include "thanos.selectorLabels" $context | fromYaml }}
{{- $monitorSelectors := deepCopy ($obj.selectorLabels | default dict) }}
{{- $_ := set $obj "selectorLabels" (mustMergeOverwrite $selectors $monitorSelectors) }}
{{- include "prometheus.serviceMonitor" (list $context $labels $obj) }}
{{- end }}
