{{/*
Expand the name of the chart.
*/}}
{{- define "visilitator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "visilitator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "visilitator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "visilitator.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
  Determine the hostname to use for PostgreSQL.
*/}}
{{- define "postgresql.hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s.%s.svc.cluster.local" (printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-") .Release.Namespace -}}
{{- else -}}
{{- printf "%s" .Values.postgresql.postgresServer -}}
{{- end -}}
{{- end -}}

{{/*
  Determine the hostname to use for RabbitMQ.
*/}}
{{- define "rabbitmq.hostname" -}}
{{- if .Values.rabbitmq.enabled -}}
{{- printf "%s.%s.svc.cluster.local" (printf "%s-%s" .Release.Name "rabbitmq" | trunc 63 | trimSuffix "-") .Release.Namespace -}}
{{- else -}}
{{- printf "%s" .Values.rabbitmq.rabbitmqServer -}}
{{- end -}}
{{- end -}}
