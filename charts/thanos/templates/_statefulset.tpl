{{- define "thanos.statefulset" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy $root.Values.common }}
{{- $overrides := deepCopy .settings }}
{{- $workload := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $workload = include "thanos.workload" (dict "context" $context "workload" $workload) | fromYaml }}
{{- $_ := set $workload "enabled" true }}
{{- include "core.statefulset" (list $context $labels $workload) }}
{{- end }}
