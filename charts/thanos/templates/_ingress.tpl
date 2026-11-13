{{- define "thanos.ingress" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.ingress | default dict) }}
{{- $overrides := deepCopy (.ingress | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- include "core.ingress" (list $context $labels $obj) }}
{{- end }}
