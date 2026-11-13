{{- define "thanos.configMaps" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $_ := set $root "serviceKey" .serviceKey }}
{{- $defaults := deepCopy ($root.Values.common.configMaps | default dict) }}
{{- $overrides := deepCopy (.configMaps | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $labels := include "thanos.labels" $root | fromYaml }}
{{- $name := include "thanos.stackFullName" $root }}
{{- range $key, $resource := $obj }}
{{- $resource := deepCopy $resource }}
{{- $_ := set $resource "name" ($resource.name | default (printf "%s-%s" $name $key)) }}
{{- if not (hasKey $resource "namespace") }}
{{- $_ := set $resource "namespace" (include "thanos.namespace" $root) }}
{{- end }}
{{- include "core.configMap" (list $root $labels $resource) }}
{{- end }}
{{- end }}
