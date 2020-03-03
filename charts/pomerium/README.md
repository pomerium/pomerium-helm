# Pomerium

[Pomerium](https://pomerium.io) is an [open-source](https://github.com/pomerium/pomerium) tool for managing secure access to internal applications and resources.

- [Pomerium](#pomerium)
  - [TL;DR;](#tldr)
  - [Install the chart](#install-the-chart)
  - [Uninstalling the Chart](#uninstalling-the-chart)
  - [Pomerium Operator (EXPERIMENTAL)](#pomerium-operator-experimental)
  - [TLS Certificates](#tls-certificates)
    - [Ingress Controller Annotations](#ingress-controller-annotations)
    - [Auto Generation](#auto-generation)
    - [Self Provisioned](#self-provisioned)
  - [Configuration](#configuration)
  - [Changelog](#changelog)
    - [6.0.0](#600)
    - [5.0.0](#500)
    - [4.0.0](#400)
    - [3.0.0](#300)
    - [2.0.0](#200)
  - [Upgrading](#upgrading)
    - [5.0.0](#500-1)
    - [4.0.0](#400-1)
    - [3.0.0](#300-1)
    - [2.0.0](#200-1)
  - [Metrics Discovery Configuration](#metrics-discovery-configuration)
    - [Prometheus Operator](#prometheus-operator)
    - [Prometheus kubernetes_sd_configs](#prometheus-kubernetessdconfigs)

## TL;DR;

```console
helm install my-release pomerium/pomerium
```

> Note: Pomerium depends on being configured with a third party identity providers to function properly. If you run pomerium without specifying default values, you will need to change those configuration variables following setup.

## Install the chart

An example of a minimal, but complete installation of pomerium with identity provider settings, random secrets, certificates, and external URLs is as follows:

```sh
helm install my-release pomerium/pomerium\
	--set config.rootDomain="corp.beyondperimeter.com" \
	--set config.sharedSecret=$(head -c32 /dev/urandom | base64) \
	--set config.cookieSecret=$(head -c32 /dev/urandom | base64) \
	--set authenticate.idp.provider="google" \
	--set authenticate.idp.clientID="REPLACE_ME" \
	--set authenticate.idp.clientSecret="REPLACE_ME"
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete --purge my-release
```

The command removes nearly all the Kubernetes components associated with the chart and deletes the release.

## Pomerium Operator (EXPERIMENTAL)

To provide dynamic pomerium configuration, an [operator](https://github.com/pomerium/pomerium-operator) is being introduced to this chart.

To enable pomerium-operator, set `operator.enabled` to `true`.  Your existing values should continue to work as-is.  Enabling it will allow you to take advantage of `Service` and `Ingress` annotations to dynamically configure pomerium policies.

See https://github.com/pomerium/pomerium-operator#using for information on how to use these annotations.

Operator based deplyoment is experimental.  Please report any issues!

## TLS Certificates

### Ingress Controller Annotations

Pomerium uses TLS for all components.  You may need to configure your ingress controller to communicate with pomerium over TLS.

### Auto Generation

In default configuration, this chart will automatically generate TLS certificates in a helm `pre-install` hook for the Pomerium services to communicate with.

Upon delete, you will need to manually delete the generated secrets. Example:

```console
kubectl delete secret -l app.kubernetes.io/name=pomerium
```

You may force recreation of your TLS certificates by setting `config.forceGenerateTLS` to `true`. Delete any existing TLS secrets first to prevent errors, and make sure you set back to `false` for your next helm upgrade command or your deployment will fail due to existing Secrets.

### Self Provisioned

If you wish to provide your own TLS certificates in secrets, you should:

1. turn `generateTLS` to `false`
2. specify `authenticate.existingTLSSecret`, `authorize.existingTLSSecret`, and `proxy.existingTLSSecret`, pointing at the appropriate TLS certificate for each service.

All services can share the secret if appropriate.

## Configuration

A full listing of Pomerium's configuration variables can be found on the [config reference page](https://www.pomerium.io/docs/reference/reference.html).

| Parameter                             | Description                                                                                                                                                                                                                                                                                        | Default                                                                               |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `nameOverride`                        | Name of the chart.                                                                                                                                                                                                                                                                                 | `pomerium`                                                                            |
| `fullnameOverride`                    | Full name of the chart.                                                                                                                                                                                                                                                                            | `pomerium`                                                                            |
| `config.rootDomain`                   | Root Domain specifies the sub-domain handled by pomerium. [See more](https://www.pomerium.io/docs/reference/reference.html#proxy-root-domains).                                                                                                                                                    | `corp.pomerium.io`                                                                    |
| `config.administrators`     | Comma seperated list of email addresses of administrative users [See more](https://www.pomerium.io/configuration/#administrators).                                                                                                                                                                      | Optional                                                                              |
| `config.existingSecret`               | Name of the existing Kubernetes Secret.                                                                                                                                                                                                                                                            |                                                                                       |
| `config.existingConfig`               | Name of the existing Config Map deployed on Kubernetes.                                                                                                                                                                                                                                            |                                                                                       |
| `config.existingCASecret`             | Name of the existing CA Secret.                                                                                                                                                                                                                                                                    |                                                                                       |
| `config.generateTLS`                  | Generate a dummy Certificate Authority and certs for service communication. Manual CA and certs can be set in values.                                                                                                                                                                              | `true`                                                                                |
| `config.forceGenerateTLS`             | Force recreation of generated TLS certificates. You will need to restart your deployments after running                                                                                                                                                                                            | `false`                                                                               |
| `config.sharedSecret`                 | 256 bit key to secure service communication. [See more](https://www.pomerium.io/docs/reference/reference.html#shared-secret).                                                                                                                                                                      | 32 [random ascii chars](http://masterminds.github.io/sprig/strings.html)              |
| `config.cookieSecret`                 | Cookie secret is a 32 byte key used to encrypt user sessions.                                                                                                                                                                                                                                      | 32 [random ascii chars](http://masterminds.github.io/sprig/strings.html)              |
| `config.policy`                       | Base64 encoded string containing the routes, and their access policies.                                                                                                                                                                                                                            |                                                                                       |
| `config.policyFile`                   | Relative file location of the policy file which contains the routes, and their access policies.                                                                                                                                                                                                    | [See example](https://www.pomerium.io/docs/reference/reference.html#policy) in values |
| `authenticate.nameOverride`           | Name of the authenticate service.                                                                                                                                                                                                                                                                  | `authenticate`                                                                        |
| `authenticate.fullnameOverride`       | Full name of the authenticate service.                                                                                                                                                                                                                                                             | `authenticate`                                                                        |
| `authenticate.redirectUrl`            | Redirect URL is the url the user will be redirected to following authentication with the third-party identity provider (IdP). [See more](https://www.pomerium.io/docs/reference/reference.html#redirect-url).                                                                                      | `https://{{authenticate.name}}.{{config.rootDomain}}/oauth2/callback`                 |
| `authenticate.idp.provider`           | Identity [Provider Name](https://www.pomerium.io/docs/reference/reference.html#identity-provider-name).                                                                                                                                                                                            | `google`                                                                              |
| `authenticate.idp.clientID`           | Identity Provider oauth [client ID](https://www.pomerium.io/docs/reference/reference.html#identity-provider-client-id).                                                                                                                                                                            | Required                                                                              |
| `authenticate.idp.clientSecret`       | Identity Provider oauth [client secret](https://www.pomerium.io/docs/reference/reference.html#identity-provider-client-secret).                                                                                                                                                                    | Required                                                                              |
| `authenticate.idp.url`                | Identity [Provider URL](https://www.pomerium.io/docs/reference/reference.html#identity-provider-url).                                                                                                                                                                                              | Optional                                                                              |
| `authenticate.idp.scopes`             | Identity [Provider Scopes](https://www.pomerium.io/configuration/#identity-provider-scopes).                                                                                                                                                                                                       | Optional                                                                              |
| `authenticate.idp.serviceAccount`     | Identity Provider [service account](https://www.pomerium.io/docs/reference/reference.html#identity-provider-service-account).                                                                                                                                                                      | Optional                                                                              |
| `authenticate.replicaCount`           | Number of Authenticate pods to run                                                                                                                                                                                                                                                                 | `1`                                                                                   |
| `authenticate.existingTLSSecret`      | Name of existing TLS Secret for authenticate service                                                                                                                                                                                                                                               |                                                                                       |
| `authenticate.deployment.annotations` | Annotations for the authenticate deployment. If none given, then use value of `annotations`                                                                                                                                                                                                        | `{}`                                                                                  |
| `authenticate.service.annotations`    | Annotations for the authenticate service. If none given, then use value of `service.annotations`                                                                                                                                                                                                   | `{}`                                                                                  |
| `authenticate.cacheServiceUrl`        | The internally accesible url for the cache service.                                                                                                                                                                                                                                                | `https://{{cache.name}}.{{config.rootDomain}}`                                        |
| `proxy.nameOverride`                  | Name of the proxy service.                                                                                                                                                                                                                                                                         | `proxy`                                                                               |
| `proxy.fullnameOverride`              | Full name of the proxy service.                                                                                                                                                                                                                                                                    | `proxy`                                                                               |
| `proxy.authenticateServiceUrl`        | The externally accessible url for the authenticate service.                                                                                                                                                                                                                                        | `https://{{authenticate.name}}.{{config.rootDomain}}`                                 |
| `proxy.replicaCount`                  | Number of Proxy pods to run                                                                                                                                                                                                                                                                        | `1`                                                                                   |
| `proxy.existingTLSSecret`             | Name of existing TLS Secret for proxy service                                                                                                                                                                                                                                                      |                                                                                       |
| `proxy.deployment.annotations`        | Annotations for the proxy deployment. If none given, then use value of `annotations`                                                                                                                                                                                                               | `{}`                                                                                  |
| `proxy.service.annotations`           | Annotations for the proxy service. If none given, then use value of `service.annotations`                                                                                                                                                                                                          | `{}`                                                                                  |
| `proxy.signingKey`                    | Signing key is the base64 encoded key used to sign outbound requests.                                                                                                                                                                                                                              |                                                                                       |
| `authorize.nameOverride`              | Name of the authorize service.                                                                                                                                                                                                                                                                     | `authorize`                                                                           |
| `authorize.fullnameOverride`          | Full name of the authorize service.                                                                                                                                                                                                                                                                | `authorize`                                                                           |
| `authorize.replicaCount`              | Number of Authorize pods to run                                                                                                                                                                                                                                                                    | `1`                                                                                   |
| `authorize.existingTLSSecret`         | Name of existing TLS Secret for authorize service                                                                                                                                                                                                                                                  |                                                                                       |
| `forwardAuth.nameOverride`            | External name of the forward-auth endpoint                                                                                                                                                                                                                                                         | `forwardauth.${rootDomain}`                                                           |
| `forwardAuth.enabled`                 | Enable forward-auth endpoint for third party ingress controllers to use for auth checks. Setting this disables automatic enumeration of `from` hostnames in the Pomerium Ingress object to prevent conflicts. Use `ingress.hosts` to mix forward-auth and proxy mode on a single Pomerium instance | `false`                                                                               |
| `authorize.deployment.annotations`    | Annotations for the authorize deployment. If none given, then use value of `annotations`                                                                                                                                                                                                           | `{}`                                                                                  |
| `authorize.service.annotations`       | Annotations for the authorize service. If none given, then use value of `service.annotations`                                                                                                                                                                                                      | `{}`                                                                                  |
| `images.server.repository`            | Pomerium image                                                                                                                                                                                                                                                                                     | `pomerium/pomerium`                                                                   |
| `images.server.tag`                   | Pomerium image tag                                                                                                                                                                                                                                                                                 | `v0.5.2`                                                                              |
| `images.server.pullPolicy`            | Pomerium image pull policy                                                                                                                                                                                                                                                                         | `IfNotPresent`                                                                        |
| `service.annotations`                 | Service annotations                                                                                                                                                                                                                                                                                | `{}`                                                                                  |
| `service.externalPort`                | Pomerium's port                                                                                                                                                                                                                                                                                    | `443`                                                                                 |
| `service.type`                        | Service type (ClusterIP, NodePort or LoadBalancer)                                                                                                                                                                                                                                                 | `ClusterIP`                                                                           |
| `service.authorize.headless`          | Run Authorize service in Headless mode. Turn off if you **require** NodePort or LoadBalancer access to Authorize                                                                                                                                                                                   | `true`                                                                                |
| `serviceMonitor.enabled`              | Create Prometheus Operator ServiceMonitor                                                                                                                                                                                                                                                          | `false`                                                                               |
| `serviceMonitor.namespace`            | Namespace to create the ServiceMonitor resource in                                                                                                                                                                                                                                                 | The namespace of the chart                                                            |
| `serviceMonitor.labels`               | Additional labels to apply to the ServiceMonitor resource                                                                                                                                                                                                                                          | `release: prometheus`                                                                 |
| `tracing.enabled`                     | Enable distributed tracing                                                                                                                                                                                                                                                                         | `false`                                                                               |
| `tracing.debug`                       | Set trace sampling to 100%. Use with caution!                                                                                                                                                                                                                                                      | `false`                                                                               |
| `tracing.provider`                    | Specifies the tracing provider to configure (Valid options: Jaeger)                                                                                                                                                                                                                                | Required                                                                              |
| `tracing.jaeger.collector_endpoint`   | The jaeger collector endpoint                                                                                                                                                                                                                                                                      | Required                                                                              |
| `tracing.jaeger.agent_endpoint`       | The jaeger agent endpoint                                                                                                                                                                                                                                                                          | Required                                                                              |
| `ingress.enabled`                     | Enables Ingress for pomerium                                                                                                                                                                                                                                                                       | `true`                                                                                |
| `ingress.annotations`                 | Ingress annotations.  Ensure you set appropriate annotations for TLS backend and large URLs if using Azure.                                                                                                                                                                                        | `{}`                                                                                  |
| `ingress.hosts`                       | Ingress accepted hostnames                                                                                                                                                                                                                                                                         | `[]`                                                                                  |
| `ingress.secretName`                  | Ingress TLS certificate secret name                                                                                                                                                                                                                                                                | `[]`                                                                                  |
| `metrics.enabled`                     | Enable prometheus metrics endpoint                                                                                                                                                                                                                                                                 | `false`                                                                               |
| `metrics.port`                        | Prometheus metrics endpoint port                                                                                                                                                                                                                                                                   | `9090`                                                                                |
| `cache.nameOverride`                  | Name of the cache service.                                                                                                                                                                                                                                                                         | `cache`                                                                               |
| `cache.fullnameOverride`              | Full name of the cache service.                                                                                                                                                                                                                                                                    | `cache`                                                                               |
| `cache.replicaCount`                  | Number of cache pods to run                                                                                                                                                                                                                                                                        | `1`                                                                                   |
| `cache.existingTLSSecret`             | Name of existing TLS Secret for authorize service                                                                                                                                                                                                                                                  |
| `operator.enabled`                    | Enable experimental pomerium operator support                                                                                                                                                                                                                                                      | false                                                                                 |
| `operator.nameOverride`               | Name of the operator                                                                                                                                                                                                                                                                               | `operator`                                                                            |
| `operator.fullnameOverride`           | Full name of the operator                                                                                                                                                                                                                                                                          | `operator`                                                                            |
| `operator.replicaCount`               | Number of operator pods to run                                                                                                                                                                                                                                                                     | `1`                                                                                   |
| `operator.image.repository`           | Pomerium Operator image                                                                                                                                                                                                                                                                            | `pomerium/pomerium-operator`                                                          |
| `operator.image.tag`                  | Pomerium Operator image tag                                                                                                                                                                                                                                                                        | `v0.0.1-rc1`                                                                          |
| `operator.config.ingressClass`        | `kubernetes.io/ingress.class` for the operator to monitor                                                                                                                                                                                                                                          | `pomerium`                                                                            |
| `operator.config.serviceClass`        | `kubernetes.io/service.class` for the operator to monitor                                                                                                                                                                                                                                          | `pomerium`                                                                            |
| `operator.config.debug`               | Enable Pomerium Operator debug logging                                                                                                                                                                                                                                                             | `false`                                                                               |
| `operator.deployment.annotations`     | Annotations for the operator deployment.                                                                                                                                                                                                                                                           | `{}`                                                                                  |

## Changelog

### 6.0.0

- Integrate pomerium operator
- Remove legacy TLS config support.  See [v3.0.0 Upgrade Notes](#300-1) to migrate

### 5.0.0

- Upgrade to Pomerium v0.6.0
- Add cache service

### 4.0.0

- Upgrade to Pomerium v0.4.0
- Handle breaking changes from Pomerium

### 3.0.0

- Refactor TLS certificates to use Kubernetes TLS secrets
- Generate TLS certificates in a hook to prevent certificate churn

### 2.0.0

- Expose replica count for individual services
- Switch Authorize service to ClusterIP for client side load balancing
  - You must run pomerium v0.3.0+ to support this feature correctly

## Upgrading

### 5.0.0

- A new service, cache, was added to this chart release.
  - If upgrading an install where pomerium had previously generated your certificates, you should set `config.forceGenerateTLS` to `true` and regenerate your certifcates during upgrade.
  - If upgrading an install which used custom certificates, be sure to set `config.existingTLSSecret` and add a new TLS certificate for the cache service.
- See [Pomerium Changelog](https://www.pomerium.io/docs/upgrading.html#since-0-5-0) for details

### 4.0.0

- There are no user facing changes in this chart release
- See [Pomerium Changelog](https://www.pomerium.io/docs/upgrading.html#since-0-3-0) for internal details

### 3.0.0

- This version moves all certificates to TLS secrets.
  - If you have existing generated certificates:
    - Let pomerium regenerate your certificates during upgrade
      - set `config.forceGenerateTLS` to `true`
      - upgrade
      - set `config.forceGenerateTLS` to `false`
    - **OR:** To retain your certificates
      - save your existing pomerium secret
      - set `config.existingLegacyTLSSecret` to `true`
      - set `config.existingConfig` to point to your configuration secret
      - upgrade
      - re-create pomerium secret from saved yaml
  - If you have externally sourced certificates in your pomerium secret:
    - [Move and convert your certificates](scripts/upgrade-v3.0.0.sh) to type TLS Secrets and configure `[service].existingTLSSecret` to point to your secrets
    - **OR:** To continue using your certificates from the existing config, set `config.existingLegacyTLSSecret` to `true`

---

### 2.0.0

- You will need to run `helm upgrade --force` to recreate the authorize service correctly

## Metrics Discovery Configuration

This chart provides two ways to surface metrics for discovery. Under normal circumstances, you will only set up one method.

### Prometheus Operator

This chart assumes you have already installed the Prometheus Operator CRDs.

Example chart values:

```yaml
metrics:
  enabled: true
  port: 9090 # default
serviceMonitor:
  enabled: true
  labels:
    release: prometheus # default
```

Example ServiceMonitor configuration:

```yaml
serviceMonitorSelector:
  matchLabels:
    release: prometheus # operator chart default
```

### Prometheus kubernetes_sd_configs

Example chart values:

```yaml
metrics:
  enabled: true
  port: 9090 # default
service:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
```

Example prometheus discovery config:

```yaml
- job_name: 'pomerium'
metrics_path: /metrics
kubernetes_sd_configs:
- role: endpoints
relabel_configs:
- source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
  action: keep
  regex: true
- source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_instance]
  action: keep
  regex: pomerium
- action: labelmap
  regex: __meta_kubernetes_service_label_(.+)
- source_labels: [__meta_kubernetes_namespace]
  action: replace
  target_label: kubernetes_namespace
- source_labels: [__meta_kubernetes_service_name]
  action: replace
  target_label: kubernetes_name
- source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
  action: replace
  regex: ([^:]+)(?::\d+)?;(\d+)
  replacement: $1:$2
  target_label: __address__
```
