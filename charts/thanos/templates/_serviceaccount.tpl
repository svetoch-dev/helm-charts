{{- define "thanos.serviceAccount" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.serviceAccount | default dict) }}
{{- $overrides := deepCopy (.serviceAccount | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $_ := set $obj "name" (include "thanos.component.serviceAccountName" $root) }}
{{- if not (hasKey $obj "namespace") }}
{{- $_ := set $obj "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.serviceAccount" (list $root $labels $obj) }}
{{- end }}
