{{/* vim: set filetype=mustache: */}}

{{/*Expand the name of the chart.*/}}
{{- define "pomerium.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the proxy-service.*/}}
{{- define "pomerium.proxy.name" -}}
{{- default (printf "%s-proxy" .Chart.Name) .Values.proxy.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the authenticate-service.*/}}
{{- define "pomerium.authenticate.name" -}}
{{- default (printf "%s-authenticate" .Chart.Name) .Values.authenticate.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the authorize-service.*/}}
{{- define "pomerium.authorize.name" -}}
{{- default (printf "%s-authorize" .Chart.Name) .Values.authorize.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the databroker-service.*/}}
{{- define "pomerium.databroker.name" -}}
{{- default (printf "%s-databroker" .Chart.Name) .Values.databroker.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the ingressController .*/}}
{{- define "pomerium.ingressController.name" -}}
{{- default (printf "%s-ingress-controller" .Chart.Name) .Values.ingressController.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the redis subchart .*/}}
{{- define "pomerium.redis.name" -}}
{{- printf "%s-redis" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pomerium.fullname" -}}
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

{{/* Proxy services fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.proxy.fullname" -}}
{{- if .Values.proxy.fullnameOverride -}}
{{- .Values.proxy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-proxy" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-proxy" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* authorize services fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.authorize.fullname" -}}
{{- if .Values.authorize.fullnameOverride -}}
{{- .Values.authorize.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-authorize" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-authorize" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* databroker services fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.databroker.fullname" -}}
{{- if .Values.databroker.fullnameOverride -}}
{{- .Values.databroker.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-databroker" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-databroker" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* authenticate services fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.authenticate.fullname" -}}
{{- if .Values.authenticate.fullnameOverride -}}
{{- .Values.authenticate.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-authenticate" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-authenticate" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* ingressController fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.ingressController.fullname" -}}
{{- if .Values.ingressController.fullnameOverride -}}
{{- .Values.ingressController.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-ingress-controller" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-ingress-controller" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*Create chart name and version as used by the chart label.*/}}
{{- define "pomerium.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pomerium.routestring" -}}
{{- $routes := dict "routes" (list) -}}
{{- range $key, $val := .Values.proxy.routes -}}
{{- $noop := printf "%s=%s" $key $val | append $routes.routes | set $routes "routes" -}}
{{- end -}}
{{- join "," $routes.routes | default "none=none" | quote -}}
{{- end -}}

{{/*
Check if a valid identity provider has been set
Adapted from : https://github.com/helm/charts/blob/master/stable/drone/templates/_provider-envs.yaml
*/}}
{{- define "pomerium.providerOK" -}}
{{- if .Values.authenticate.idp -}}
  {{- if .Values.config.existingSecret -}}
  true
  {{- else if and .Values.authenticate.deployment.extraEnv.IDP_CLIENT_ID .Values.authenticate.deployment.extraEnv.IDP_CLIENT_SECRET -}}
  true
  {{- else if eq .Values.authenticate.idp.clientID "" -}}
  false
  {{- else if eq .Values.authenticate.idp.clientSecret "" -}}
  false
  {{- else if eq .Values.authenticate.idp.clientID "REPLACE_ME" -}}
  false
  {{- else if eq .Values.authenticate.idp.clientSecret "REPLACE_ME" -}}
  false
  {{- else -}}
  true
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* Determine secret name for Authenticate TLS Cert */}}
{{- define "pomerium.authenticate.tlsSecret.name" -}}
{{- if .Values.authenticate.existingTLSSecret -}}
{{- .Values.authenticate.existingTLSSecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-authenticate-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-authenticate-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Determine secret name for Authorize TLS Cert */}}
{{- define "pomerium.authorize.tlsSecret.name" -}}
{{- if .Values.authorize.existingTLSSecret -}}
{{- .Values.authorize.existingTLSSecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-authorize-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-authorize-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Determine secret name for databroker TLS Cert */}}
{{- define "pomerium.databroker.tlsSecret.name" -}}
{{- if .Values.databroker.existingTLSSecret -}}
{{- .Values.databroker.existingTLSSecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-databroker-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-databroker-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Determine secret name for Proxy TLS Cert */}}
{{- define "pomerium.proxy.tlsSecret.name" -}}
{{- if .Values.proxy.existingTLSSecret -}}
{{- .Values.proxy.existingTLSSecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-proxy-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-proxy-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Determine secret name for signing key */}}
{{- define "pomerium.signingKeySecret.name" -}}
{{- if .Values.config.existingSigningKeySecret -}}
{{- .Values.config.existingSigningKeySecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-signing-key" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-signing-key" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pomerium.caSecret.name" -}}
{{if .Values.config.existingCASecret }}
{{- .Values.config.existingCASecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-ca-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-ca-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*Expand the FQDN of the forward-auth endpoint.*/}}
{{- define "pomerium.forwardAuth.name" -}}
{{- if .Values.forwardAuth.name -}}
{{- .Values.forwardAuth.name -}}
{{- else if .Values.forwardAuth.internal -}}
{{- printf "%s.%s" (include "pomerium.proxy.fullname" .) ( .Release.Namespace ) -}}
{{- else -}}
{{- printf "forwardauth.%s" .Values.config.rootDomain -}}
{{- end -}}
{{- end -}}

{{/*Expand the FQDN of the api proxy endpoint*/}}
{{- define "pomerium.apiProxy.name" -}}
{{- if .Values.apiProxy.fullNameOverride -}}
{{- .Values.apiProxy.fullNameOverride -}}
{{- else -}}
{{- printf "%s.%s" .Values.apiProxy.name .Values.config.rootDomain -}}
{{- end -}}
{{- end -}}

{{/*Expand the serviceAccountName for the authenticate service */}}
{{- define "pomerium.authenticate.serviceAccountName" -}}
{{- default (printf "%s-authenticate" ( include "pomerium.fullname" .) ) .Values.authenticate.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the authorize service */}}
{{- define "pomerium.authorize.serviceAccountName" -}}
{{- default (printf "%s-authorize" ( include "pomerium.fullname" .) ) .Values.authorize.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the databroker service */}}
{{- define "pomerium.databroker.serviceAccountName" -}}
{{- default (printf "%s-databroker" ( include "pomerium.fullname" .) ) .Values.databroker.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the proxy service */}}
{{- define "pomerium.proxy.serviceAccountName" -}}
{{- default (printf "%s-proxy" ( include "pomerium.fullname" .) ) .Values.proxy.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the ingressController */}}
{{- define "pomerium.ingressController.serviceAccountName" -}}
{{- default (printf "%s-ingress-controller" ( include "pomerium.fullname" .) ) .Values.ingressController.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the name of the config secret */}}
{{- define "pomerium.secretName" -}}
{{- default (include "pomerium.fullname" .) .Values.config.existingSecret -}}
{{- end -}}

{{/*Expand the name of the shared parameters secret */}}
{{- define "pomerium.sharedSecretName" -}}
{{- if and .Values.config.existingSharedSecret -}}
{{- .Values.config.existingSharedSecret -}}
{{- else -}}
{{- printf "%s-shared" (include "pomerium.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*Expand the port number for secure or insecure mode */}}
{{- define "pomerium.trafficPort.number" -}}
{{- if .Values.config.insecure -}}
80
{{- else -}}
443
{{- end -}}
{{- end -}}

{{/*Expand the http port name for secure or insecure mode */}}
{{- define "pomerium.httpTrafficPort.name" -}}
{{- if .Values.config.insecure -}}
{{- default "http" .Values.service.httpTrafficPort.nameOverride -}}
{{- else -}}
{{- default "https" .Values.service.httpTrafficPort.nameOverride -}}
{{- end -}}
{{- end -}}

{{/*Expand the http port scheme for secure or insecure mode */}}
{{- define "pomerium.httpTrafficPort.scheme" -}}
{{- if .Values.config.insecure -}}
http
{{- else -}}
https
{{- end -}}
{{- end -}}

{{/*Expand the proxy's http port scheme for secure or insecure mode */}}
{{- define "pomerium.proxy.httpTrafficPort.scheme" -}}
{{- if (include "pomerium.proxy.insecure" .) -}}
http
{{- else -}}
https
{{- end -}}
{{- end -}}

{{/*Expand the proxy's port number for secure or insecure mode */}}
{{- define "pomerium.proxy.trafficPort.number" -}}
{{- if (include "pomerium.proxy.insecure" .) -}}
80
{{- else -}}
443
{{- end -}}
{{- end -}}


{{/*
Expand the grpc port name for secure or insecure mode

grpc is used for insecure rather than http for istio compatibility
*/}}
{{- define "pomerium.grpcTrafficPort.name" -}}
{{- if .Values.config.insecure -}}
{{- default "grpc" .Values.service.grpcTrafficPort.nameOverride -}}
{{- else -}}
{{- default "https" .Values.service.grpcTrafficPort.nameOverride -}}
{{- end -}}
{{- end -}}

{{/*Expand the service port number for secure or insecure mode */}}
{{- define "pomerium.service.externalPort" -}}
{{- if .Values.service.externalPort -}}
{{- .Values.service.externalPort -}}
{{- else -}}
{{-   if .Values.config.insecure -}}
80
{{-   else -}}
443
{{-   end -}}
{{- end -}}
{{- end -}}

{{/* Expand databroker client tls path */}}
{{- define "pomerium.databroker.storage.clientTLS.path" -}}
/pomerium/databroker-client-tls
{{- end -}}

{{/* Expand Data Broker Client TLS Secret */}}
{{- define "pomerium.databroker.storage.clientTLS.secret" -}}
{{ if .Values.databroker.storage.clientTLS.existingSecretName }}
{{- .Values.databroker.storage.clientTLS.existingSecretName -}}
{{- else if ( include "pomerium.redis.tlsCertsGenerated" . ) -}}
{{- include "pomerium.redis.tlsSecret.name" . -}}
{{- else -}}
{{- default (printf "%s-databroker-client-tls" (include "pomerium.fullname" .)) .Values.databroker.storage.clientTLS.existingSecretName -}}
{{- end -}}
{{- end -}}

{{/* Data Broker Storage Configuration */}}
{{- define "pomerium.databroker.tlsEnv" -}}
{{- if or .Values.databroker.storage.clientTLS.existingSecretName .Values.databroker.storage.clientTLS.cert  ( include "pomerium.redis.tlsCertsGenerated" . )}}
- name: DATABROKER_STORAGE_CERT_FILE
  value: {{ include "pomerium.databroker.storage.clientTLS.path" . }}/tls.crt
- name: DATABROKER_STORAGE_KEY_FILE
  value: {{ include "pomerium.databroker.storage.clientTLS.path" . }}/tls.key
{{- end  }}
{{- if or .Values.databroker.storage.clientTLS.existingCASecretKey .Values.databroker.storage.clientTLS.ca ( include "pomerium.redis.tlsCertsGenerated" . ) }}
- name: DATABROKER_STORAGE_CA_FILE
  value: {{ include "pomerium.databroker.storage.clientTLS.path" . }}/{{ default "ca.crt" .Values.databroker.storage.clientTLS.existingCASecretKey }}
{{- end  }}
{{- end -}}

{{/* Pomerium internal TLS certificate env var*/}}
{{- define "pomerium.tls.internal.envVars" }}
- name: CERTIFICATE_FILE
  value: /pomerium/tls/tls.crt
- name: CERTIFICATE_KEY_FILE
  value: /pomerium/tls/tls.key
{{- end }}

{{/*Creates static configuration yaml */}}
{{- define "pomerium.config.static" -}}
autocert: false
dns_lookup_family: V4_ONLY
address: :{{ template "pomerium.trafficPort.number" . }}
grpc_address: :{{ template "pomerium.trafficPort.number" . }}
{{- if not .Values.config.insecure }}
certificate_authority_file: "/pomerium/ca/ca.crt"
certificates:
{{-   range .Values.extraTLSSecrets }}
  - cert: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}/tls.crt
    key: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}/tls.key
{{-   end }}
{{- with .Values.authenticate.existingExternalTLSSecret }}
  - cert: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}/tls.crt
    key: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}/tls.key
{{- end }}
{{- end }}
authenticate_service_url: {{ default (printf "https://%s" ( include "pomerium.authenticate.hostname" . ) ) .Values.proxy.authenticateServiceUrl }}
authorize_service_url: {{ default (printf "%s://%s.%s.svc.cluster.local" (include "pomerium.httpTrafficPort.name" .) (include "pomerium.authorize.fullname" .) .Release.Namespace ) .Values.proxy.authorizeInternalUrl}}
databroker_service_url: {{ default (printf "%s://%s.%s.svc.cluster.local" (include "pomerium.httpTrafficPort.name" .) (include "pomerium.databroker.fullname" .) .Release.Namespace ) .Values.authenticate.databrokerServiceUrl}}
idp_provider: {{ .Values.authenticate.idp.provider }}
idp_scopes: {{ .Values.authenticate.idp.scopes }}
idp_provider_url: {{ .Values.authenticate.idp.url }}
{{- if .Values.config.insecure }}
insecure_server: true
grpc_insecure: true
{{- end }}
{{- if and .Values.config.existingPolicy .Values.config.extraOpts }}
{{ fail "Cannot use config.extraOpts with config.existingPolicy" }}
{{- end }}
{{- if and .Values.config.existingPolicy .Values.config.routes }}
{{ fail "Cannot use .Values.config.routes with config.existingPolicy" }}
{{- end }}
{{- if .Values.config.administrators }}
administrators: {{ .Values.config.administrators | quote }}
{{- end -}}
{{- if .Values.config.extraOpts }}

{{ toYaml .Values.config.extraOpts -}}
{{- end -}}
{{- if .Values.tracing.enabled }}
tracing_debug: {{ .Values.tracing.debug }}
tracing_provider: {{ required "tracing_provider is required for tracing" .Values.tracing.provider }}

{{- if eq .Values.tracing.provider "jaeger" }}
tracing_jaeger_collector_endpoint: {{ required "collector_endpoint is required for jaeoger tracing" .Values.tracing.jaeger.collector_endpoint }}
tracing_jaeger_agent_endpoint: {{ required "agent_endpoint is required for jaeger tracing" .Values.tracing.jaeger.agent_endpoint }}
{{- end -}}

{{- end -}}
{{- if and .Values.forwardAuth.enabled .Values.forwardAuth.internal }}
forward_auth_url: {{ printf "%s://%s" ( include "pomerium.httpTrafficPort.name" . ) ( include "pomerium.forwardAuth.name" . ) }}
{{- else if .Values.forwardAuth.enabled }}
forward_auth_url: {{ printf "https://%s" ( include "pomerium.forwardAuth.name" . ) }}
{{- end }}
idp_client_id: {{ .Values.authenticate.idp.clientID }}
idp_client_secret: {{ .Values.authenticate.idp.clientSecret }}
{{- if ne (include "pomerium.databroker.storage.type" . ) "memory" }}
databroker_storage_tls_skip_verify: {{ .Values.databroker.storage.tlsSkipVerify }}
{{- end  }}
{{- end -}}

{{/* Creates dynamic configuration yaml */}}
{{- define "pomerium.config.dynamic" -}}
{{- if or .Values.config.routes .Values.authenticate.proxied }}
routes:
{{-   if .Values.config.routes }}
{{-    if kindIs "string" .Values.config.routes }}
{{       tpl .Values.config.routes . | indent 2 }}
{{-    else }}
{{       tpl (toYaml .Values.config.routes) . | indent 2 }}
{{-    end  }}
{{-   end }}
{{- if and .Values.authenticate.proxied (not .Values.ingressController.enabled) }}
  - from: https://{{ include "pomerium.authenticate.hostname" . }}
    to: {{ printf "%s://%s.%s.svc.cluster.local" (include "pomerium.httpTrafficPort.name" .) (include "pomerium.authenticate.fullname" .) .Release.Namespace }}
    allow_public_unauthenticated_access: true
{{- end }}
{{- end }}
{{- end -}}

{{- define "pomerium.volumeMounts" -}}
- mountPath: /etc/pomerium/
  name: config
- mountPath: /pomerium/tls
  name: service-tls
- mountPath: /pomerium/ca
  name: ca-tls
{{- range .Values.extraTLSSecrets }}
- mountPath: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}
  name: {{ . }}
{{- end }}
{{- with .Values.authenticate.existingExternalTLSSecret }}
- mountPath: {{include "pomerium.extraTLSSecret.path" . }}{{ . }}
  name: {{ . }}
{{- end }}
{{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts }}
{{- end }}
{{- end -}}

{{/* Generates common volumes for all services */}}
{{- define "pomerium.volumes.shared" -}}
- name: config
  secret:
    secretName: {{ include "pomerium.secretName" . }}
- name: ca-tls
  secret:
    secretName: {{ template "pomerium.caSecret.name" . }}
    optional: true
{{- range .Values.extraTLSSecrets }}
- name: {{ . }}
  secret:
    secretName: {{ . }}
{{- end }}
{{- with .Values.authenticate.existingExternalTLSSecret }}
- name: {{ . }}
  secret:
    secretName: {{ . }}
{{- end }}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
{{- end -}}

{{/* Generates volumes specific to a service */}}
{{- define "pomerium.volumes.service" -}}
- name: service-tls
  secret:
    secretName: {{ include (printf "pomerium.%s.tlsSecret.name" .currentServiceName ) . }}
    optional: true
{{- end -}}

{{/* Limit databroker replica count by storage backend */}}
{{- define "pomerium.databroker.replicaCount" -}}
{{- if eq "memory" (include "pomerium.databroker.storage.type" . ) -}}
1
{{- else -}}
{{ default .Values.replicaCount .Values.databroker.replicaCount -}}
{{- end -}}
{{- end -}}

{{/* Expand databroker storage type */}}
{{- define "pomerium.databroker.storage.type" -}}
{{- if .Values.redis.enabled -}}
redis
{{- else -}}
{{- .Values.databroker.storage.type -}}
{{- end -}}
{{- end -}}

{{/* Render databroker connection string */}}
{{- define "pomerium.databroker.storage.connectionString" -}}
{{- if .Values.redis.enabled -}}
{{- default (printf "%s://:%s@%s-master.%s.svc.cluster.local:6379" (include "pomerium.redis.scheme" . ) (include "pomerium.redis.password" . ) (include "pomerium.redis.name" . ) .Release.Namespace ) .Values.databroker.storage.connectionString -}}
{{- else -}}
{{- .Values.databroker.storage.connectionString -}}
{{- end -}}
{{- end -}}

{{/* Render redis password */}}
{{- define "pomerium.redis.password" -}}
{{- if .Values.redis.password -}}
{{- .Values.redis.password -}}
{{- else if .Values.config.sharedSecret -}}
{{-  .Values.config.sharedSecret | sha256sum -}}
{{- else -}}
{{- randAscii 32 -}}
{{- end -}}
{{- end -}}

{{/* Render redis scheme */}}
{{- define "pomerium.redis.scheme" -}}
{{- if .Values.redis.tls.enabled -}}
rediss
{{- else -}}
redis
{{- end -}}
{{- end -}}

{{/* Expand redis TLS secret name */}}
{{- define "pomerium.redis.tlsSecret.name" -}}
{{- .Values.redis.tls.certificatesSecret -}}
{{- end -}}

{{/* Expand to check if we generated and are using TLS certs with embedded redis */}}
{{- define "pomerium.redis.tlsCertsGenerated" -}}
{{- if and .Values.redis.generateTLS .Values.redis.tls.enabled .Values.redis.enabled -}}
true
{{- else -}}
{{- end -}}
{{- end -}}

{{/* Expand ingress TLS hosts list */}}
{{- define "pomerium.ingress.tls.hosts" -}}
{{- if .Values.ingress.tls.hosts -}}
{{ .Values.ingress.tls.hosts | toYaml }}
{{- else -}}
- {{ template "pomerium.authenticate.hostname" . }}
  {{- if and (.Values.forwardAuth.enabled) (not .Values.forwardAuth.internal) }}
- {{ template "pomerium.forwardAuth.name" . }}
  {{ end }}
{{- if not (or .Values.ingress.hosts .Values.forwardAuth.enabled) }}
{{- range .Values.config.routes }}
{{- if hasPrefix "http" .from }}
- {{ .from | trimPrefix "https://" | trimPrefix "http://" | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- range .Values.ingress.hosts }}
- {{ . | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Return the hostname of the authenticate service
*/}}
{{- define "pomerium.authenticate.hostname" -}}
{{ printf "%s.%s" (.Values.authenticate.name | default "authenticate") .Values.config.rootDomain }}
{{- end -}}

{{/* Expand the extraTLSSecret file path */}}
{{- define "pomerium.extraTLSSecret.path" }}
{{- print "/etc/pomerium/tls/" }}
{{- end }}

{{/* Return metrics env var block */}}
{{- define "pomerium.metrics.envVars" }}
{{- if .Values.metrics.enabled }}
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: METRICS_PORT
  value: "{{ .Values.metrics.port }}"
- name: METRICS_ADDRESS
  value: "$(POD_IP):$(METRICS_PORT)"
{{- end }}
{{- end }}

{{/* Returns checksum for values that you should restart pods for */}}
{{- define "pomerium.static.checksum" }}
{{- print .Values.config.sharedSecret .Values.config.cookieSecret (toString .Values.authenticate.idp) .Values.config.forceGenerateServiceSecrets (toString .Values.databroker.storage) | sha256sum }}
{{- end }}

{{/* Determine if the downstream edge of Pomerium Proxy should be secure */}}
{{- define "pomerium.proxy.insecure" }}
{{- if or (and .Values.config.insecure (and .Values.ingressController.enabled (.Values.ingressController.config.operatorMode))) (or (and .Values.config.insecure .Values.config.insecureProxy) (and .Values.config.insecure (not .Values.ingressController.enabled))) -}}
true
{{- end -}}
{{- end }}

{{/* Render secret name for databroker storage secret */}}
{{- define "pomerium.databroker.storage.secret" }}
{{- if .Values.redis.enabled -}}
{{ .Values.redis.auth.existingSecret }}
{{- else -}}
{{- printf "%s-storage" (include "pomerium.databroker.name" .) -}}
{{- end -}}
{{- end }}
