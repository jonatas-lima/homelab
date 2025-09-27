{{/*
Expand the name of the chart.
*/}}
{{- define "prowlarr.name" -}}
{{- default "prowlarr" .Values.prowlarr.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prowlarr.fullname" -}}
{{- if .Values.prowlarr.fullnameOverride }}
{{- .Values.prowlarr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "prowlarr" .Values.prowlarr.nameOverride }}
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
{{- define "prowlarr.chart" -}}
{{- printf "%s-%s" "prowlarr" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prowlarr.labels" -}}
helm.sh/chart: {{ include "prowlarr.chart" . }}
{{ include "prowlarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prowlarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prowlarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prowlarr.serviceAccountName" -}}
{{- if .Values.prowlarr.serviceAccount.create }}
{{- default (include "prowlarr.fullname" .) .Values.prowlarr.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.prowlarr.serviceAccount.name }}
{{- end }}
{{- end }}
