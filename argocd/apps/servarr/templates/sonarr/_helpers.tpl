{{/*
Expand the name of the chart.
*/}}
{{- define "sonarr.name" -}}
{{- default "sonarr" .Values.sonarr.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sonarr.fullname" -}}
{{- if .Values.sonarr.fullnameOverride }}
{{- .Values.sonarr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "sonarr" .Values.sonarr.nameOverride }}
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
{{- define "sonarr.chart" -}}
{{- printf "%s-%s" "sonarr" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sonarr.labels" -}}
helm.sh/chart: {{ include "sonarr.chart" . }}
{{ include "sonarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sonarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sonarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sonarr.serviceAccountName" -}}
{{- if .Values.sonarr.serviceAccount.create }}
{{- default (include "sonarr.fullname" .) .Values.sonarr.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.sonarr.serviceAccount.name }}
{{- end }}
{{- end }}
