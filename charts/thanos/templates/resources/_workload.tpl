{{- define "thanos.workload" }}
{{- $root := .root }}
{{- $global := $root.Values.global | default dict }}
{{- $workload := deepCopy .workload }}
{{- $name := include "thanos.stackFullName" $root }}
{{- $_ := set $workload "name" $name }}
{{- $_ := set $workload "selectorLabels" (include "thanos.selectorLabels" $root | fromYaml) }}
{{- $image := $global.image | default dict }}
{{- $_ := set $workload "imagePullPolicy" $workload.image.pullPolicy }}
{{- $_ := set $workload "image" (printf "%s:%s" ($workload.image.repository | default $image.repository) ($workload.image.tag | default $image.tag)) }}
{{- $_ := set $workload "serviceAccountName" (include "thanos.component.serviceAccountName" $root) }}
{{- range $key := list "nodeSelector" "tolerations" "affinity" }}
{{- if not (hasKey $workload $key) }}
{{- $_ := set $workload $key (index $global $key) }}
{{- end }}
{{- end }}
{{- $settings := get $root.Values $root.serviceKey }}
{{- $defaults := $root.Values.common.workload.environment | default list }}
{{- $service := $settings.workload.environment | default list }}
{{- $environment := concat $defaults $service }}
{{- $_ := set $workload "env" $environment }}
{{- $mounts := $workload.volumeMounts | default list }}
{{- $initContainers := list }}
{{- range $key, $container := $workload.initContainers }}
{{- $item := deepCopy $container }}
{{- $_ := set $item "name" ($item.name | default $key) }}
{{- $_ := set $item "env" $environment }}
{{- $_ := unset $item "envFrom" }}
{{- if and $mounts (not (hasKey $item "volumeMounts")) }}
{{- $_ := set $item "volumeMounts" $mounts }}
{{- end }}
{{- $initContainers = append $initContainers $item }}
{{- end }}
{{- $_ := set $workload "initContainers" $initContainers }}
{{- $sidecars := list }}
{{- range $container := $workload.sidecars }}
{{- $item := deepCopy $container }}
{{- $_ := set $item "env" $environment }}
{{- $_ := unset $item "envFrom" }}
{{- $sidecars = append $sidecars $item }}
{{- end }}
{{- $_ := set $workload "sidecars" $sidecars }}
{{- toYaml $workload }}
{{- end }}
