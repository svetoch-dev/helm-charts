{{- define "infra.repoURL" -}}
{{- required "global.repo.url is required" .Values.global.repo.url -}}
{{- end -}}

{{- define "infra.generatedChartApps" -}}
{{- $generatedApps := dict -}}
{{- $overrides := .overrides | default dict -}}
{{- range $appKey, $app := .apps -}}
{{- $override := index $overrides $appKey | default dict -}}
{{- $chartName := $override.chart_name | default $appKey -}}
{{- $appName := $app.name | default $appKey -}}
{{- $namespace := $override.namespace | default $app.namespace | default $app.name | default $appKey -}}
{{- $enabled := true -}}
{{- if and (hasKey $app "enabled") (kindIs "bool" $app.enabled) -}}
{{- $enabled = $app.enabled -}}
{{- end -}}
{{- $postgresEnabled := false -}}
{{- if and (hasKey $app "postgres") (kindIs "bool" $app.postgres) -}}
{{- $postgresEnabled = $app.postgres -}}
{{- end -}}
{{- $rabbitmqEnabled := false -}}
{{- if and (hasKey $app "rabbitmq") (kindIs "bool" $app.rabbitmq) -}}
{{- $rabbitmqEnabled = $app.rabbitmq -}}
{{- end -}}
{{- $redisEnabled := false -}}
{{- if and (hasKey $app "redis") (kindIs "bool" $app.redis) -}}
{{- $redisEnabled = $app.redis -}}
{{- end -}}
{{- $deployments := dict -}}
{{- $services := dict -}}
{{- if $postgresEnabled -}}
{{- $postgresService := printf "{{ printf \"%s-%%s-postgres-cluster\" .Values.global.env.cloud_short_name }}" $chartName -}}
{{- $_ := set $deployments "postgres" $postgresService -}}
{{- $_ = set $services "postgres" $postgresService -}}
{{- end -}}
{{- if $rabbitmqEnabled -}}
{{- $rabbitmqService := printf "{{ printf \"%s-%%s-rabbitmq-cluster\" .Values.global.env.cloud_short_name }}" $chartName -}}
{{- $_ := set $deployments "rmq" $rabbitmqService -}}
{{- $_ = set $services "rmq" $rabbitmqService -}}
{{- end -}}
{{- if $redisEnabled -}}
{{- $_ := set $services "redis" (printf "{{ printf \"%s-%%s-redis-sentinel-sentinel\" .Values.global.env.cloud_short_name }}" $chartName) -}}
{{- end -}}
{{- $globalValues := dict
      "access" (dict "roles" (list "admin" "dev"))
      "ingress" (dict "class" "konghq-app") -}}
{{- with $deployments -}}
{{- $_ := set $globalValues "deployments" . -}}
{{- end -}}
{{- with $services -}}
{{- $_ := set $globalValues "svc" . -}}
{{- end -}}
{{- $_ := set $generatedApps $chartName (dict
      "enabled" $enabled
      "name" (printf "{{ printf \"%s-%%s\" .Values.global.env.cloud_short_name }}" $appName)
      "namespace" $namespace
      "app" true
      "globalValues" $globalValues) -}}
{{- end -}}
{{- toYaml $generatedApps -}}
{{- end -}}
