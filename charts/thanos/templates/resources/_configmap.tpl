{{- define "thanos.configMaps" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.configMaps | default dict) }}
{{- $overrides := deepCopy (.configMaps | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- range $key, $resource := $obj }}
{{- $resource := deepCopy $resource }}
{{- $_ := set $resource "name" ($resource.name | default (printf "%s-%s" $name $key)) }}
{{- include "core.configMap" (list $root $labels $resource) }}
{{- end }}
{{- end }}
