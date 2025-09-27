{{/*
Expand the name of the chart.
*/}}
{{- define "qbittorrent.name" -}}
{{- default "qbittorrent" .Values.qbittorrent.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "qbittorrent.fullname" -}}
{{- if .Values.qbittorrent.fullnameOverride }}
{{- .Values.qbittorrent.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "qbittorrent" .Values.qbittorrent.nameOverride }}
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
{{- define "qbittorrent.chart" -}}
{{- printf "%s-%s" "qbittorrent" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "qbittorrent.labels" -}}
helm.sh/chart: {{ include "qbittorrent.chart" . }}
{{ include "qbittorrent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "qbittorrent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qbittorrent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "qbittorrent.serviceAccountName" -}}
{{- if .Values.qbittorrent.serviceAccount.create }}
{{- default (include "qbittorrent.fullname" .) .Values.qbittorrent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.qbittorrent.serviceAccount.name }}
{{- end }}
{{- end }}
