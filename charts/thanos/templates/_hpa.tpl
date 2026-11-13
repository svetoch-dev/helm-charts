{{- define "thanos.autoscaling" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.autoscaling | default dict) }}
{{- $overrides := deepCopy (.autoscaling | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $obj "name" ($obj.name | default $name) }}
{{- $_ := set $obj "targetName" $name }}
{{- $metrics := list }}
{{- range $resource, $key := dict "cpu" "targetCPUUtilizationPercentage" "memory" "targetMemoryUtilizationPercentage" }}
{{- with index $obj $key }}
{{- $metrics = append $metrics (dict "type" "Resource" "resource" (dict "name" $resource "target" (dict "type" "Utilization" "averageUtilization" .))) }}
{{- end }}
{{- end }}
{{- $_ := set $obj "metrics" $metrics }}
{{- if not (hasKey $obj "namespace") }}
{{- $_ := set $obj "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.horizontalPodAutoscaler" (list $root $labels $obj) }}
{{- end }}
