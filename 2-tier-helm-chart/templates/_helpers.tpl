{{/*
Expand the name of the chart.
*/}}
{{- define "2-tier-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "2-tier-app.fullname" -}}
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
{{- define "2-tier-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "2-tier-app.labels" -}}
helm.sh/chart: {{ include "2-tier-app.chart" . }}
{{ include "2-tier-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "2-tier-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "2-tier-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL labels
*/}}
{{- define "2-tier-app.mysql.labels" -}}
{{ include "2-tier-app.labels" . }}
app: {{ .Values.mysql.labels.app }}
tier: {{ .Values.mysql.labels.tier }}
{{- end }}

{{/*
MySQL selector labels
*/}}
{{- define "2-tier-app.mysql.selectorLabels" -}}
{{ include "2-tier-app.selectorLabels" . }}
app: {{ .Values.mysql.labels.app }}
tier: {{ .Values.mysql.labels.tier }}
{{- end }}

{{/*
Webapp labels
*/}}
{{- define "2-tier-app.webapp.labels" -}}
{{ include "2-tier-app.labels" . }}
app: {{ .Values.webapp.labels.app }}
tier: {{ .Values.webapp.labels.tier }}
{{- end }}

{{/*
Webapp selector labels
*/}}
{{- define "2-tier-app.webapp.selectorLabels" -}}
{{ include "2-tier-app.selectorLabels" . }}
app: {{ .Values.webapp.labels.app }}
tier: {{ .Values.webapp.labels.tier }}
{{- end }}
