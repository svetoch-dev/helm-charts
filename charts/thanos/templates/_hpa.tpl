{{- define "thanos.autoscaling" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.autoscaling | default dict) }}
{{- $overrides := deepCopy (.autoscaling | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $name := include "thanos.stackFullName" $context }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "targetName" $name }}
{{- $metrics := list }}
{{- range $resource, $key := dict "cpu" "targetCPUUtilizationPercentage" "memory" "targetMemoryUtilizationPercentage" }}
{{- with index $obj $key }}
{{- $metrics = append $metrics (dict "type" "Resource" "resource" (dict "name" $resource "target" (dict "type" "Utilization" "averageUtilization" .))) }}
{{- end }}
{{- end }}
{{- $_ := set $obj "metrics" $metrics }}
{{- include "core.horizontalPodAutoscaler" (list $context $labels $obj) }}
{{- end }}
