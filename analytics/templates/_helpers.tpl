{{/*
Expand the name of the chart.
*/}}
{{- define "analytics.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Block data producers until Alembic reaches the configured revision. */}}
{{- define "analytics.revisionGate" -}}
{{- if and .Values.cli.enabled .Values.cli.migrations.enabled }}
initContainers:
  - name: wait-for-database-revision
    image: "{{ .Values.cli.image.repository }}:{{ .Values.cli.image.tag }}"
    imagePullPolicy: {{ .Values.cli.image.pullPolicy }}
    command: ["/bin/sh", "-ec"]
    args:
      - |
        until analytics-cli db require-revision --revision {{ .Values.cli.migrations.targetRevision | quote }}; do
          echo "Database migration is not ready; retrying in 2 seconds"
          sleep 2
        done
    envFrom:
      - secretRef:
          name: {{ include "analytics.timescaledb-env-secret-name" . | quote }}
    env:
      {{- include "analytics.timescaledb-envs" . | nindent 6 }}
      - name: GEORCHESTRA_ANALYTICS_CLI_CONFIG_FILE
        value: /etc/georchestra/analytics/cli.yaml
    volumeMounts:
      - name: cli-config
        subPath: cli.yaml
        mountPath: /etc/georchestra/analytics/cli.yaml
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "analytics.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "analytics.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "analytics.labels" -}}
helm.sh/chart: {{ include "analytics.chart" . }}
{{ include "analytics.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "analytics.selectorLabels" -}}
app.kubernetes.io/name: {{ include "analytics.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

