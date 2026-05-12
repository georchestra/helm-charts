{{/*
Insert database environment variables
*/}}
{{- define "datafeeder-python.database-envs" -}}
{{- $database := .Values.airflow.postgresql -}}
{{- $database_secret_datafeeder_name := printf "%s-database-backend" (include "datafeeder-python.fullname" .) -}}
{{- if .Values.backend.database.existingSecret }}
{{- $database_secret_datafeeder_name = .Values.backend.database.existingSecret -}}
{{- end }}
- name: PGHOST
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_datafeeder_name }}
        key: host
        optional: false
- name: PGPORT
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_datafeeder_name }}
        key: port
        optional: false
- name: PGDATABASE
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_datafeeder_name }}
        key: dbname
        optional: false
- name: PGUSER
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_datafeeder_name }}
        key: user
        optional: false
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_datafeeder_name }}
        key: password
        optional: false
{{- end }}
{{- define "datafeeder-python.data-database-envs" -}}
{{- $data_database_secret_name := printf "%s-database-data" (include "datafeeder-python.fullname" .) -}}
{{- if .Values.backend.data_db.existingSecret }}
{{- $data_database_secret_name = .Values.backend.data_db.existingSecret -}}
{{- end }}
- name: POSTGRES_DATA_HOST
  valueFrom:
    secretKeyRef:
        name: {{ $data_database_secret_name }}
        key: host
        optional: false
- name: POSTGRES_DATA_PORT
  valueFrom:
    secretKeyRef:
        name: {{ $data_database_secret_name }}
        key: port
        optional: false
- name: POSTGRES_DATA_USER
  valueFrom:
    secretKeyRef:
        name: {{ $data_database_secret_name }}
        key: user
        optional: false
- name: POSTGRES_DATA_PASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $data_database_secret_name }}
        key: password
        optional: false
- name: POSTGRES_DATA_DB
  valueFrom:
    secretKeyRef:
        name: {{ $data_database_secret_name }}
        key: dbname
        optional: false
{{- end }}
