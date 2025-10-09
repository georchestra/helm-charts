{{/*
Insert rabbitmq georchestra environment variables
*/}}
{{- define "georchestra.rabbitmq-georchestra-envs" -}}
{{- $rabbitmq := .Values.rabbitmq -}}
{{- $rabbitmq_secret_georchestra_name := "" -}}
{{- if $rabbitmq.auth.existingSecret }}
{{- $rabbitmq_secret_georchestra_name = $rabbitmq.auth.existingSecret -}}
{{- else }}
{{- $rabbitmq_secret_georchestra_name = printf "%s-rabbitmq-georchestra-secret" (include "georchestra.fullname" .) -}}
{{- end }}
{{- if not $rabbitmq.auth.host }}
- name: RABBITMQ_HOST
  value: "{{ include "georchestra.fullname" . }}-rabbitmq"
{{- else }}
- name: RABBITMQ_HOST
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: host
        optional: false
{{- end }}
- name: RABBITMQ_PORT
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: port
        optional: false
- name: RABBITMQ_USERNAME
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: user
        optional: false
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: password
        optional: false
{{- end }}
