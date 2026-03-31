{{/*
Expand the name of the chart.
*/}}
{{- define "bazarr.name" -}}
{{- default "bazarr" .Values.bazarr.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bazarr.fullname" -}}
{{- if .Values.bazarr.fullnameOverride }}
{{- .Values.bazarr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "bazarr" .Values.bazarr.nameOverride }}
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
{{- define "bazarr.chart" -}}
{{- printf "%s-%s" "bazarr" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bazarr.labels" -}}
helm.sh/chart: {{ include "bazarr.chart" . }}
{{ include "bazarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bazarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bazarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bazarr.serviceAccountName" -}}
{{- if .Values.bazarr.serviceAccount.create }}
{{- default (include "bazarr.fullname" .) .Values.bazarr.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.bazarr.serviceAccount.name }}
{{- end }}
{{- end }}
