{{- define "thanos.deployment" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy $root.Values.common }}
{{- $overrides := deepCopy .settings }}
{{- $workload := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $workload = include "thanos.workload" (dict "root" $root "workload" $workload) | fromYaml }}
{{- $_ := set $workload "enabled" true }}
{{- include "core.deployment" (list $root $labels $workload) }}
{{- end }}
