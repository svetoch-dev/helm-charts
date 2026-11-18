{{- define "thanos.statefulset" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy $root.Values.common.workload }}
{{- $overrides := deepCopy (.workload | default dict) }}
{{- $workload := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $workload = include "thanos.workload" (dict "root" $root "workload" $workload) | fromYaml }}
{{- $_ := set $workload "enabled" true }}
{{- include "core.statefulset" (list $root $labels $workload) }}
{{- end }}
