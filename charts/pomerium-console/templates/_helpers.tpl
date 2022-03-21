{{/*
Expand the name of the chart.
*/}}
{{- define "pomerium-console.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pomerium-console.valuesCheck" -}}
{{- required "database.type must be set" .Values.database.type }}
{{- if not (eq .Values.database.type "sqlite") }}
{{-     required "database.name must be set" .Values.database.name }}
{{-     required "database.host must be set" .Values.database.host }}
{{- end }}
{{- required "config.sharedSecret must be set" .Values.config.sharedSecret }}
{{- required "config.databaseEncryptionKey must be set" .Values.config.databaseEncryptionKey }}
{{- required "config.audience must be set" .Values.config.audience }}
{{- required "config.licenseKey" .Values.config.licenseKey -}}
{{ if not (or .Values.config.signingKey .Values.config.authenticateServiceUrl)}}
{{ fail "config.signingKey or config.authenticateServiceUrl must be set" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pomerium-console.fullname" -}}
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
{{- define "pomerium-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pomerium-console.labels" -}}
helm.sh/chart: {{ include "pomerium-console.chart" . }}
{{ include "pomerium-console.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pomerium-console.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pomerium-console.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pomerium-console.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pomerium-console.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Set web port name */}}
{{- define "pomerium-console.web.scheme" -}}
{{- if .Values.tls.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{/* Set web port number */}}
{{- define "pomerium-console.web.port" -}}
{{- if .Values.tls.enabled -}}
443
{{- else -}}
80
{{- end -}}
{{- end -}}

{{/* Set grpc port name */}}
{{- define "pomerium-console.grpc.name" -}}
grpc
{{- end -}}

{{/* Set web port number */}}
{{- define "pomerium-console.grpc.port" -}}
{{- if .Values.tls.enabled -}}
444
{{- else -}}
81
{{- end -}}
{{- end -}}

{{/* Expand secret name */}}
{{- define "pomerium-console.secretName" -}}
{{ default (include "pomerium-console.fullname" . ) .Values.existingSecret }}
{{- end }}

{{/* Generate config checksum */}}
{{- define "pomerium-console.config.checksum" -}}
{{- include (print $.Template.BasePath "/secret.yaml") . | sha256sum -}}
{{- end -}}

{{/* Expand TLS secret name */}}
{{- define "pomerium-console.tls.secret" -}}
{{ default (printf "%s-tls" (include "pomerium-console.fullname" . )) .Values.tls.existingSecret }}
{{- end }}

{{/* Expand TLS CA secret name */}}
{{- define "pomerium-console.tls.ca.secret" -}}
{{ default (printf "%s-ca-tls" (include "pomerium-console.fullname" . )) .Values.tls.existingCASecret }}
{{- end }}

{{/* Expand database TLS secret name */}}
{{- define "pomerium-console.database.tls.secret" -}}
{{ default (printf "%s-database-tls" (include "pomerium-console.fullname" . )) .Values.database.tls.existingSecret }}
{{- end }}

{{/* Expand TLS CA secret name */}}
{{- define "pomerium-console.database.tls.ca.secret" -}}
{{ default (printf "%s-database-ca-tls" (include "pomerium-console.fullname" . )) .Values.database.tls.existingCASecret }}
{{- end }}

{{/* Expand DSN */}}
{{- define "pomerium-console.database.dsn" -}}
{{- $proto := (printf "%s" .Values.database.type) }}
{{- $credentials := join ":" (mustCompact (list .Values.database.username .Values.database.password )) }}
{{- $host := .Values.database.host -}}
{{- $name := .Values.database.name }}
{{- $tlsOptions := join "&" (mustCompact (list (include "pomerium-console.database.tls.sslmode" .) ( include "pomerium-console.database.tls.clientCerts" .) (include "pomerium-console.database.tls.clientCA" .) )) }}
{{- $options := join "&" (mustCompact (list $tlsOptions .Values.database.additionalDSNOptions )) }}
{{- if eq $proto "sqlite" }}
{{-     print "sqlite:/mnt/storage/console.sqlite3" }}
{{- else -}}
{{-     printf "%s://%s@%s/%s?%s" $proto $credentials $host $name $options}}
{{- end }}
{{- end }}

{{/* Expand database sslmode option */}}
{{- define "pomerium-console.database.tls.sslmode" -}}
{{- if eq .Values.database.type "my" }}
{{-     printf "tls=%s" .Values.database.sslmode }}
{{- else if eq .Values.database.type "pg" }}
{{-     printf "sslmode=%s" .Values.database.sslmode }}
{{- end }}
{{- end }}

{{/* Expand database client TLS options  */}}
{{- define "pomerium-console.database.tls.clientCerts" -}}
{{- if or (and .Values.database.tls.cert .Values.database.tls.key) (.Values.database.tls.existingSecret) -}}
{{- print "sslcert=/pomerium/db-cert.pem&sslkey=/pomerium/db-key.pem" }}
{{- end }}
{{- end }}

{{/* Expand database client TLS CA option  */}}
{{- define "pomerium-console.database.tls.clientCA" -}}
{{- if or .Values.database.tls.ca .Values.database.tls.existingCASecret -}}
{{/* sslrootcert if pg driver, sslca otherwise (my driver) */}}
{{- printf "%s=/pomerium/db-ca.pem" (ternary "sslrootcert" "sslca" (eq .Values.database.type "pg") ) }}
{{- end }}
{{- end }}

{{/* Expand Pull Secret Name */}}
{{- define "pomerium-console.pullSecret.name" -}}
{{ printf "%s-pull-secret" (include "pomerium-console.fullname" . ) }}
{{- end }}

{{/* Expand deployment Pull Secrets */}}
{{- define "pomerium-console.deployment.pullSecrets" -}}
{{ if .Values.imagePullSecrets }}
{{-     with .Values.imagePullSecrets }}
imagePullSecrets:
{{-     toYaml . | nindent 2 }}
{{- end }}
{{- else if or .Values.image.pullUsername .Values.image.pullPassword -}}
imagePullSecrets:
- name: {{ include "pomerium-console.pullSecret.name" . }}
{{- end }}
{{- end }}

{{/* Expand Pull Secret */}}
{{- define "pomerium-console.pullSecret.data" -}}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" "docker.cloudsmith.io" .Values.image.pullUsername .Values.image.pullPassword (printf "%s:%s" .Values.image.pullUsername .Values.image.pullPassword | b64enc) | b64enc }}
{{- end }}
