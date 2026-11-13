{{- define "thanos.serviceAccount" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.serviceAccount | default dict) }}
{{- $overrides := deepCopy (.serviceAccount | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $_ := set $obj "name" (include "thanos.component.serviceAccountName" $context) }}
{{- include "core.serviceAccount" (list $context $labels $obj) }}
{{- end }}
