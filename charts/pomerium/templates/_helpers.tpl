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

{{/*Expand the name of the cache-service.*/}}
{{- define "pomerium.cache.name" -}}
{{- default (printf "%s-cache" .Chart.Name) .Values.cache.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*Expand the name of the operator .*/}}
{{- define "pomerium.operator.name" -}}
{{- default (printf "%s-operator" .Chart.Name) .Values.operator.nameOverride | trunc 63 | trimSuffix "-" -}}
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

{{/* cache services fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.cache.fullname" -}}
{{- if .Values.cache.fullnameOverride -}}
{{- .Values.cache.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-cache" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-cache" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
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

{{/* operator fully qualified name. Truncated at 63 chars. */}}
{{- define "pomerium.operator.fullname" -}}
{{- if .Values.operator.fullnameOverride -}}
{{- .Values.operator.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-operator" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-operator" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
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

{{/* Determine secret name for cache TLS Cert */}}
{{- define "pomerium.cache.tlsSecret.name" -}}
{{- if .Values.cache.existingTLSSecret -}}
{{- .Values.cache.existingTLSSecret | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-cache-tls" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-cache-tls" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
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
{{- if .Values.forwardAuth.nameOverride -}}
{{- .Values.forwardAuth.nameOverride -}}
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

{{/*Expand the serviceAccountName for the cache service */}}
{{- define "pomerium.cache.serviceAccountName" -}}
{{- default (printf "%s-cache" ( include "pomerium.fullname" .) ) .Values.cache.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the proxy service */}}
{{- define "pomerium.proxy.serviceAccountName" -}}
{{- default (printf "%s-proxy" ( include "pomerium.fullname" .) ) .Values.proxy.serviceAccount.nameOverride -}}
{{- end -}}

{{/*Expand the serviceAccountName for the operator */}}
{{- define "pomerium.operator.serviceAccountName" -}}
{{- default (printf "%s-operator" ( include "pomerium.fullname" .) ) .Values.forwardAuth.nameOverride -}}
{{- end -}}

{{/*Expand the configMap for operator election */}}
{{- define "pomerium.operator.electionConfigMap" -}}
{{- printf "%s-election" ( include "pomerium.operator.name" .) -}}
{{- end -}}

{{/*Expand the name of the config secret */}}
{{- define "pomerium.secretName" -}}
{{- if and .Values.config.existingSecret (not .Values.operator.enabled) -}}
{{- .Values.config.existingSecret -}}
{{- else -}}
{{- include "pomerium.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*Expand the name of the config secret */}}
{{- define "pomerium.baseSecretName" -}}
{{- if .Values.operator.enabled -}}
{{- default (printf "%s-base" (include "pomerium.fullname" .)) .Values.config.existingSecret -}}
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

{{/*Creates static configuration yaml */}}
{{- define "pomerium.config.static" -}}
address: ":{{ template "pomerium.trafficPort.number" . }}"
grpc_address: ":{{ template "pomerium.trafficPort.number" . }}"
{{- if not .Values.config.insecure }}
certificate_file: "/pomerium/cert.pem"
certificate_key_file: "/pomerium/privkey.pem"
certificate_authority_file: "/pomerium/ca.pem"
{{- end }}
authenticate_service_url: {{ default (printf "https://authenticate.%s" .Values.config.rootDomain ) .Values.proxy.authenticateServiceUrl }}
authorize_service_url: {{ default (printf "%s://%s.%s.svc.cluster.local" (include "pomerium.httpTrafficPort.name" .) (include "pomerium.authorize.fullname" .) .Release.Namespace ) .Values.proxy.authorizeInternalUrl}}
databroker_service_url: {{ default (printf "%s://%s.%s.svc.cluster.local" (include "pomerium.httpTrafficPort.name" .) (include "pomerium.cache.fullname" .) .Release.Namespace ) .Values.authenticate.cacheServiceUrl}}
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
{{- if and .Values.config.existingPolicy .Values.config.policy }}
{{ fail "Cannot use config.policy with config.existingPolicy" }}
{{- end }}
{{- if .Values.config.administrators }}
administrators: {{ .Values.config.administrators | quote }}
{{- end -}}
{{- if .Values.config.extraOpts }}

{{ toYaml .Values.config.extraOpts -}}
{{- end -}}
{{- if .Values.metrics.enabled }}
metrics_address: ":{{ .Values.metrics.port }}"
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
cookie_secret: {{ default (randAscii 32 | b64enc) .Values.config.cookieSecret }}
shared_secret: {{ default (randAscii 32 | b64enc) .Values.config.sharedSecret }}
idp_client_id: {{ .Values.authenticate.idp.clientID }}
idp_client_secret: {{ .Values.authenticate.idp.clientSecret }}
{{- if or .Values.authenticate.idp.serviceAccount .Values.authenticate.idp.serviceAccountYAML }}
idp_service_account: {{ include "pomerium.idp.serviceAccount" . }}
{{- end }}
databroker_storage_type: {{ include "pomerium.databroker.storage.type" . }}
{{- if ne (include "pomerium.databroker.storage.type" . ) "memory" }}
databroker_storage_connection_string: {{ include "pomerium.databroker.storage.connectionString" . }}
databroker_storage_tls_skip_verify: {{ .Values.databroker.storage.tlsSkipVerify }}
{{- end  }}
{{- end -}}

{{/* Creates dynamic configuration yaml */}}
{{- define "pomerium.config.dynamic" -}}
{{- if .Values.config.policy }}
policy:
{{ tpl (toYaml .Values.config.policy) . | indent 2 }}
{{- end }}
{{- end -}}

{{- define "pomerium.volumeMounts" -}}
- mountPath: /etc/pomerium/
  name: config
- mountPath: /pomerium/cert.pem
  name: service-tls
  subPath: tls.crt
- mountPath: /pomerium/privkey.pem
  name: service-tls
  subPath: tls.key
- mountPath: /pomerium/ca.pem
  name: ca-tls
  subPath: ca.crt
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

{{/* Limit cache replica count by storage backend */}}
{{- define "pomerium.cache.replicaCount" -}}
{{- if eq "memory" (include "pomerium.databroker.storage.type" . ) -}}
1
{{- else -}}
{{ default .Values.replicaCount .Values.cache.replicaCount -}}
{{- end -}}
{{- end -}}

{{/* Render idp_service_account */}}
{{- define "pomerium.idp.serviceAccount" -}}
{{- if .Values.authenticate.idp.serviceAccount -}}
{{- .Values.authenticate.idp.serviceAccount -}}
{{- else -}}
{{- .Values.authenticate.idp.serviceAccountYAML | toJson | b64enc -}}
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
{{- randAlphaNum 10 -}}
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
- {{ printf "authenticate.%s" .Values.config.rootDomain | quote }}
  {{- if and (.Values.forwardAuth.enabled) (not .Values.forwardAuth.internal) }}
- {{ template "pomerium.forwardAuth.name" . }}
  {{ end }}
{{- if not (or .Values.ingress.hosts .Values.forwardAuth.enabled) }}
{{- range .Values.config.policy }}
- {{ .from | trimPrefix "https://" | trimPrefix "http://" | quote }}
{{- end }}
{{- end }}
{{- range .Values.ingress.hosts }}
- {{ . | quote }}
{{- end }}
{{- end -}}
{{- end -}}
