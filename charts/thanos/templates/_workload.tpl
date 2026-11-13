{{/* Mutate only the private context supplied by a resource helper. */}}
{{- define "thanos.component.context" }}
{{- $root := .root }}
{{- $stackName := include "thanos.name" $root }}
{{- $stackFullname := include "thanos.fullname" $root }}
{{- $defaults := deepCopy $root.Values.common }}
{{- $overrides := deepCopy .settings }}
{{- $values := mustMergeOverwrite $defaults $overrides }}
{{- $_ := set $values "global" (deepCopy ($root.Values.global | default dict)) }}
{{- $_ := set $root "stackName" $stackName }}
{{- $_ := set $root "stackFullname" $stackFullname }}
{{- $_ := set $root "Values" $values }}
{{- with $values.fullnameOverride }}
{{- $_ := set $root "componentFullname" (tpl . $root | trunc 63 | trimSuffix "-") }}
{{- end }}
{{- end }}

{{- define "thanos.component.serviceAccountName" }}
{{- if .Values.serviceAccount.create }}
{{- tpl (.Values.serviceAccount.name | default (include "thanos.stackFullName" .)) . }}
{{- else }}
{{- tpl (.Values.serviceAccount.name | default "default") . }}
{{- end }}
{{- end }}

{{- define "thanos.workload" }}
{{- $context := .context }}
{{- $workload := deepCopy .workload }}
{{- $name := include "thanos.stackFullName" $context }}
{{- $_ := set $workload "name" $name }}
{{- $_ := set $workload "selectorLabels" (include "thanos.selectorLabels" $context | fromYaml) }}
{{- $image := $context.Values.global.image | default dict }}
{{- $_ := set $workload "image" (printf "%s:%s" ($workload.image.repository | default $image.repository) ($workload.image.tag | default $image.tag)) }}
{{- $_ := set $workload "imagePullPolicy" $context.Values.image.pullPolicy }}
{{- $_ := set $workload "serviceAccountName" (include "thanos.component.serviceAccountName" $context) }}
{{- range $key := list "nodeSelector" "tolerations" "affinity" }}
{{- if not (hasKey $workload $key) }}
{{- $_ := set $workload $key (index $context.Values.global $key) }}
{{- end }}
{{- end }}
{{- $env := list }}
{{- if not $workload.disableGlobalEnvironmentFromSecrets }}
{{- $env = concat $env ($context.Values.global.environmentFromSecrets | default list) }}
{{- end }}
{{- $env = concat $env ($workload.environmentFromSecrets | default list) ($workload.environment | default list) }}
{{- if not $workload.disableGlobalEnvironment }}
{{- $env = concat $env ($context.Values.global.environment | default list) }}
{{- end }}
{{- $_ := set $workload "env" $env }}
{{- $mounts := list }}
{{- $volumes := list }}
{{- range $key, $claim := $workload.pvcs }}
{{- $mounts = append $mounts (dict "name" $key "mountPath" (tpl $claim.mountPath $context)) }}
{{- $claimName := $claim.name | default (printf "%s-%s" $name $key) }}
{{- $volumes = append $volumes (dict "name" $key "persistentVolumeClaim" (dict "claimName" (tpl $claimName $context))) }}
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
