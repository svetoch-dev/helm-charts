{{- define "thanos.ingress" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.ingress | default dict) }}
{{- $overrides := deepCopy (.ingress | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- include "core.ingress" (list $root $labels $obj) }}
{{- end }}
