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
{{- $env := list }}
{{- if not $workload.disableGlobalEnvironmentFromSecrets }}
{{- $env = concat $env ($global.environmentFromSecrets | default list) }}
{{- end }}
{{- $env = concat $env ($workload.environmentFromSecrets | default list) ($workload.environment | default list) }}
{{- if not $workload.disableGlobalEnvironment }}
{{- $env = concat $env ($global.environment | default list) }}
{{- end }}
{{- $_ := set $workload "env" $env }}
{{- $mounts := list }}
{{- $volumes := list }}
{{- range $key, $claim := $workload.pvcs }}
{{- $mounts = append $mounts (dict "name" $key "mountPath" (tpl $claim.mountPath $root)) }}
{{- $claimName := $claim.name | default (printf "%s-%s" $name $key) }}
{{- $volumes = append $volumes (dict "name" $key "persistentVolumeClaim" (dict "claimName" (tpl $claimName $root))) }}
{{- end }}
{{- $mounts = concat $mounts ($workload.volumeMounts | default list) }}
{{- $_ := set $workload "volumeMounts" $mounts }}
{{- $_ := set $workload "volumes" (concat $volumes ($workload.volumes | default list)) }}
{{- $initContainers := list }}
{{- range $key, $container := $workload.initContainers }}
{{- $item := deepCopy $container }}
{{- $_ := set $item "name" ($item.name | default $key) }}
{{- if and $env (not (hasKey $item "env")) }}
{{- $_ := set $item "env" $env }}
{{- end }}
{{- if and $mounts (not (hasKey $item "volumeMounts")) }}
{{- $_ := set $item "volumeMounts" $mounts }}
{{- end }}
{{- $initContainers = append $initContainers $item }}
{{- end }}
{{- $_ := set $workload "initContainers" $initContainers }}
{{- toYaml $workload }}
{{- end }}
