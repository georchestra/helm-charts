{{/*
Name of the TimescaleDB connection secret.
*/}}
{{- define "analytics.timescaledb-connection-secret-name" -}}
{{- .Values.timescaledb.auth.existingSecret | default (printf "%s-timescaledb-connection-secret" (include "analytics.fullname" .)) -}}
{{- end }}

{{/*
Name of the TimescaleDB env secret.
*/}}
{{- define "analytics.timescaledb-env-secret-name" -}}
{{- .Values.timescaledb.auth.existingEnvSecret | default (printf "%s-timescaledb-env-secret" (include "analytics.fullname" .)) -}}
{{- end }}

{{/*
TimescaleDB TSDB_* environment variables (list items to include under env:).
*/}}
{{- define "analytics.timescaledb-envs" -}}
- name: TSDB_HOST
  valueFrom:
    secretKeyRef:
      name: {{ include "analytics.timescaledb-connection-secret-name" . | quote }}
      key: host
- name: TSDB_PORT
  valueFrom:
    secretKeyRef:
      name: {{ include "analytics.timescaledb-connection-secret-name" . | quote }}
      key: port
- name: TSDB_NAME
  valueFrom:
    secretKeyRef:
      name: {{ include "analytics.timescaledb-connection-secret-name" . | quote }}
      key: dbname
- name: TSDB_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "analytics.timescaledb-connection-secret-name" . | quote }}
      key: user
- name: TSDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "analytics.timescaledb-connection-secret-name" . | quote }}
      key: password
{{- end }}
