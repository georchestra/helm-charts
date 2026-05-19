{{/*
Insert redis environment variables for Spring Session Redis support on the gateway
*/}}
{{- define "georchestra.redis-envs" -}}
{{- $redis := .Values.redis -}}
{{- $redis_secret_name := "" -}}
{{- if $redis.auth.existingSecret }}
{{- $redis_secret_name = $redis.auth.existingSecret -}}
{{- else }}
{{- $redis_secret_name = printf "%s-redis-georchestra-secret" (include "georchestra.fullname" .) -}}
{{- end }}
- name: SPRING_SESSION_REDIS_ENABLED
  value: "true"
- name: SPRING_SESSION_REDIS_HOST
  valueFrom:
    secretKeyRef:
        name: {{ $redis_secret_name }}
        key: host
        optional: false
- name: SPRING_SESSION_REDIS_PORT
  valueFrom:
    secretKeyRef:
        name: {{ $redis_secret_name }}
        key: port
        optional: false
- name: SPRING_SESSION_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $redis_secret_name }}
        key: password
        optional: false
{{- end }}
