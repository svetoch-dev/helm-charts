{{- define "thanos.secrets" }}
{{- $root := deepCopy .root }}
{{- $_ := set $root "component" .component }}
{{- $defaults := deepCopy ($root.Values.common.secrets | default dict) }}
{{- $overrides := deepCopy (.secrets | default dict) }}
{{- $obj := mustMergeOverwrite $defaults $overrides }}
{{- $context := deepCopy $root }}
{{- include "thanos.component.context" (dict "root" $context "settings" .settings) }}
{{- $labels := include "thanos.labels" $context | fromYaml }}
{{- $name := include "thanos.stackFullName" $context }}
{{- range $key, $resource := $obj }}
{{- $resource := deepCopy $resource }}
{{- $_ := set $resource "name" ($resource.name | default (printf "%s-%s" $name $key)) }}
{{- include "core.secret" (list $context $labels $resource) }}
{{- end }}
{{- end }}
