{{- define "thanos.deployment" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy $root.Values.common.workload }}
{{- $overrides := deepCopy (.workload | default dict) }}
{{- $workload := mustMergeOverwrite $defaults $overrides }}
{{- $settings := get $root.Values $root.serviceKey }}
{{- $autoscalingDefaults := deepCopy $root.Values.common.autoscaling }}
{{- $autoscalingService := deepCopy ($settings.autoscaling | default dict) }}
{{- $_ := set $workload "autoscaling" (mustMergeOverwrite $autoscalingDefaults $autoscalingService) }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $workload = include "thanos.workload" (dict "root" $root "workload" $workload) | fromYaml }}
{{- $_ := set $workload "enabled" true }}
{{- include "core.deployment" (list $root $labels $workload) }}
{{- end }}
