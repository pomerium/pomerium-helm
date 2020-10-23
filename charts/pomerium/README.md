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
  - [Signing Key](#signing-key)
    - [Auto Generation](#auto-generation-1)
    - [Self Provisioned](#self-provisioned-1)
  - [Kubernetes API Proxy](#kubernetes-api-proxy)
  - [Redis Subchart](#redis-subchart)
  - [Configuration](#configuration)
  - [Changelog](#changelog)
    - [14.0.0](#1400)
    - [13.0.0](#1300)
    - [11.0.0](#1100)
    - [10.2.0](#1020)
    - [10.0.0](#1000)
    - [8.5.5](#855)
    - [8.5.1](#851)
    - [8.5.0](#850)
    - [8.4.0](#840)
    - [8.0.0](#800)
    - [7.0.0](#700)
    - [6.0.0](#600)
    - [5.0.0](#500)
    - [4.0.0](#400)
    - [3.0.0](#300)
    - [2.0.0](#200)
  - [Upgrading](#upgrading)
    - [14.0.0](#1400-1)
    - [13.0.0](#1300-1)
    - [12.3.0](#1230)
    - [11.0.0](#1100-1)
    - [10.0.0](#1000-1)
    - [8.0.0](#800-1)
    - [7.0.0](#700-1)
    - [5.0.0](#500-1)
    - [4.0.0](#400-1)
    - [3.0.0](#300-1)
    - [2.0.0](#200-1)
  - [Metrics Discovery Configuration](#metrics-discovery-configuration)
    - [Prometheus Operator](#prometheus-operator)
    - [Prometheus kubernetes_sd_configs](#prometheus-kubernetes_sd_configs)

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
kubectl delete secret pomerium-authenticate-tls
kubectl delete secret pomerium-authorize-tls
kubectl delete secret pomerium-ca-tls
kubectl delete secret pomerium-cache-tls
kubectl delete secret pomerium-proxy-tls
```

You may force recreation of your TLS certificates by setting `config.forceGenerateTLS` to `true`. Delete any existing TLS secrets first to prevent errors, and make sure you set back to `false` for your next helm upgrade command or your deployment will fail due to existing Secrets.

### Self Provisioned

If you wish to provide your own TLS certificates in secrets, you should:

1. turn `config.generateTLS` to `false`
2. specify `authenticate.existingTLSSecret`, `authorize.existingTLSSecret`, and `proxy.existingTLSSecret`, pointing at the appropriate TLS certificate for each service.

All services can share the secret if appropriate.

## Signing Key

### Auto Generation

In default configuration, this chart will automatically generate a signing key in a helm `pre-install` hook for the Pomerium proxy to sign jwt sent in responses.

Upon delete, you will need to manually delete the generated secret. Example:

```console
kubectl delete secret pomerium-signing-key
```

You may force recreation of your signing key by setting `config.forceGenerateSigningKey` to `true`. Delete already existing signing key secret first to prevent errors, and make sure you set back to `false` for your next helm upgrade command or your deployment will fail due to existing Secret.

### Self Provisioned

If you wish to provide your own signing key in secret, you should:

1. turn `config.generateSigningKey` to `false`
2. specify `config.existingSigningKeySecret` with secret's name

## Shared secrets

### Auto Generation

In default configuration, this chart will automatically generate a shared secret and cookie secret (as well as a password for Redis, if enabled) in a helm `pre-install` hook for Pomerium to mutually authenticate services.

Upon delete, you will need to manually delete the generated secret(s). Example:

```console
kubectl delete secret pomerium-shared-secrets
kubectl delete secret pomerium-databroker-storage # for non-memory (ie. Redis) cache
```

You may force recreation of your shared secrets by setting `config.forceGenerateSharedSecrets` to `true`. Delete already existing shared secrets first to prevent errors, and make sure you set back to `false` for your next helm upgrade command or your deployment will fail due to existing Secret.

### Self Provisioned

If you wish to provide your own shared secret / cookie secret, you should:

1. turn `config.generateSharedSecrets` to `false`
2. If not providing the variables through a mechanism like `extraEnv` or `extraEnvFrom`, specify `config.sharedSecret` and `config.cookieSecret` with 32 crypto-random bytes each, encoded as Base64

## Kubernetes API Proxy

Starting in `v0.10`, Pomerium supports delegated authentication for the Kubernetes API Server.  In this model, Kubernetes delegates authentication to Pomerium, allowing Kubernetes RBAC policies to be applied to users authenticated by Pomerium.

This feature does not require running inside the cluster, but this chart supports setting this up with minimal
configuration.

After setting `apiProxy.enabled`:

1) Add a policy entry (see `apiProxy` values for defaults):

```yaml
    - from: https://kubernetes.localhost.pomerium.io
      to: https://kubernetes.default.svc
      tls_skip_verify: true
      allowed_domains:
        - user@gmail.com
```

2) Add role bindings:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pomerium-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: user@gmail.com
```

See [docs.pomerium.io/docs/topics/data-storage.html#kubectl-auth](https://docs.pomerium.io/docs/topics/kubernetes-auth.html) for more detail and client setup.

## Redis Subchart

To support Pomerium's [storage requirements](https://www.pomerium.com/docs/topics/data-storage.html), a redis subchart can be included as part of your deployment.  To enable it, simply set `redis.enabled` to `true`.  The default configuration is intended to be secure but minimal.  See `redis.*` options in the [configuration](#configuration) section for more options.

This subchart uses [Bitnami's Helm Chart](https://github.com/bitnami/charts/tree/master/bitnami/redis), adding a handful of pomerium-specific options to ease integration.  All values starting with `redis.*` will be passed on to the redis subchart, allowing very flexible configuration.  Unless specified as part of the Pomerium values file, the defaults from the subchart are used.

As with Pomerium's own [TLS certificate support](#tls-certificates), this chart allows you to automatically bootstrap a CA and certificates used for communication with/between redis instances.  In production deployments, we recommend using an external certificate source such as [cert-manager](https://github.com/jetstack/cert-manager).

You may force recreation of these TLS certificates by setting `redis.forceGenerateTLS` to `true`. Delete the existing redis TLS secrets first to prevent errors, and make sure you set back to `false` for your next helm upgrade command or your deployment will fail due to existing Secrets.

If you are running in Istio or other secure service meshes, you may wish to set `redis.tls.enabled` to `false` to offload mtls to your mesh.

See [upgrade guide](#1230) to add to existing releases.

## Configuration

A full listing of Pomerium's configuration variables can be found on the [config reference page](https://www.pomerium.io/docs/reference/reference.html).

| Parameter                                                    | Description                                                                                                                                                                                                                                                                                        | Default                                                                     |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `nameOverride`                                               | Name of the chart.                                                                                                                                                                                                                                                                                 | `pomerium`                                                                  |
| `fullnameOverride`                                           | Full name of the chart.                                                                                                                                                                                                                                                                            | `pomerium`                                                                  |
| `config.rootDomain`                                          | Root Domain specifies the sub-domain handled by pomerium. [See more](https://www.pomerium.io/docs/reference/reference.html#proxy-root-domains).                                                                                                                                                    | `corp.pomerium.io`                                                          |
| `config.administrators`                                      | Comma seperated list of email addresses of administrative users [See more](https://www.pomerium.io/configuration/#administrators).                                                                                                                                                                 | Optional                                                                    |
| `config.existingSecret`                                      | Name of the existing Kubernetes Secret.                                                                                                                                                                                                                                                            |                                                                             |
| `config.existingCASecret`                                    | Name of the existing CA Secret.                                                                                                                                                                                                                                                                    |                                                                             |
| `config.generateSigningKey`                                  | Generate a signing key to sign jwt in proxy responses. Manual signing key can be set in values.                                                                                                                                                                                                    | `true`                                                                      |
| `config.forceGenerateSigningKey`                             | Force recreation of generated signing key. You will need to restart your deployments after running                                                                                                                                                                                                 | `false`                                                                     |
| `config.existingSigningKeySecret`                            | Name of existing Signing key Secret for proxy requests.                                                                                                                                                                                                                                            |                                                                             |
| `config.signingKey`                                          | Signing key is the base64 encoded key used to sign outbound requests.                                                                                                                                                                                                                              |                                                                             |
| `config.generateTLS`                                         | Generate a dummy Certificate Authority and certs for service communication. Manual CA and certs can be set in values.                                                                                                                                                                              | `true`                                                                      |
| `config.generateTLSAnnotations`                              | Annotations to be applied to generated TLS certificates.                                                                                                                                                                                                                                           | `{}`                                                                        |
| `config.forceGenerateTLS`                                    | Force recreation of generated TLS certificates. You will need to restart your deployments after running                                                                                                                                                                                            | `false`                                                                     |
| `config.insecure`                                            | DANGER, this disables tls between services. Only do this if you know what you are doing. One reason might be that you want to offload tls to a reverse proxy (i.e. istio, traefik)                                                                                                                 | `false`                                                                     |
| `config.sharedSecret`                                        | 256 bit key to secure service communication. [See more](https://www.pomerium.io/docs/reference/reference.html#shared-secret).                                                                                                                                                                      | 32 [random ascii chars][randAscii] (with `config.generateSharedSecrets`)    |
| `config.cookieSecret`                                        | Cookie secret is a 32 byte key used to encrypt user sessions.                                                                                                                                                                                                                                      | 32 [random ascii chars][randAscii] (with `config.generateSharedSecrets`)    |
| `config.generateSharedSecrets`                               | Initialize `SHARED_SECRET` and `COOKIE_SECRET` with random ASCII values, if undefined.                                                                                                                                                                                                             | `true`                                                                      |
| `config.lookupExistingSecrets`                               | Whether existing shared secret values, and values derived from generated secrets (ie. the Redis password), should be read from the cluster and reused.                                                                                                                                             | `true`                                                                      |
| `config.forceGenerateSharedSecrets`                          | Force recreation of generated shared secrets. You will need to restart your deployments after running                                                                                                                                                                                              | `false`                                                                     |
| `config.policy`                                              | List of routes and their policies. Accepts template values or string templates.  [See more](https://www.pomerium.com/reference/#policy).                                                                                                                                                           |                                                                             |
| `config.extraOpts`                                           | Options Dictionary appended to the config file. May contain any additional config value that doesn't have its dedicated helm value counterpart.                                                                                                                                                    | {}                                                                          |
| `databroker`                                                 | Databroker configuration options.  Supported in `v0.10+`                                                                                                                                                                                                                                           |                                                                             |
| `databroker.clientTLS.ca`                                    | Base64 encoded CA certificate for verifying the storage backend                                                                                                                                                                                                                                    |                                                                             |
| `databroker.clientTLS.cert`                                  | Base64 encoded TLS client certificate for connecting to the storage backend                                                                                                                                                                                                                        |                                                                             |
| `databroker.clientTLS.existingSecretName`                    | Name of existing secret with client certificates for the storage backend.  Certificate is expected at `tls.crt` and key is expected at `tls.key`                                                                                                                                                   |                                                                             |
| `databroker.clientTLS.existingCASecretKey`                   | Name of data key to load a CA certificate from when using `databroker.clientTLS.existingSecretName`                                                                                                                                                                                                |                                                                             |
| `databroker.clientTLS.key`                                   | Base64 encoded TLS client key for connecting to the storage backend                                                                                                                                                                                                                                |                                                                             |
| `databroker.storage.type`                                    | Databroker storage backend.  [See more](https://www.pomerium.io/reference/#cache-service)                                                                                                                                                                                                          | `memory` (when `redis.enabled` is `false`)                                  |
| `databroker.storage.autoconfigure`                           | Set environment variables to connect to non-memory databroker storage                                                                                                                                                                                                                              | `true`                                                                      |
| `databroker.storage.connectionString`                        | Databroker connection string.  [See more](https://www.pomerium.io/reference/#data-broker-storage-connection-string)                                                                                                                                                                                | derived from config automatically (with `databroker.storage.autoconfigure`) |
| `databroker.storage.tlsSkipVerify`                           | Disable TLS verfication of storage backend service                                                                                                                                                                                                                                                 | `false`                                                                     |
| `extraEnv`                                                   | Set `env` variables on service pods                                                                                                                                                                                                                                                                | []                                                                          |
| `extraEnvFrom`                                               | Sets `envFrom` on service pods.  Can be used to source ENV vars from existing secrets or configmaps.  [Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#envfromsource-v1-core)                                                                                      | []                                                                          |
| `apiProxy`                                                   | Kubernetes API Server proxy configuration options.  Supported in pomerium `v0.10+`                                                                                                                                                                                                                 |                                                                             |
| `apiProxy.enabled`                                           | Create service account, RBAC and ingress rules to proxy to the kubernetes api server on this cluster                                                                                                                                                                                               | `false`                                                                     |
| `apiProxy.ingress`                                           | When `apiProxy.enabled` is `true`, inject an entry into the pomerium ingress resource                                                                                                                                                                                                              | true                                                                        |
| `apiProxy.fullNameOverride`                                  | Set the FQDN to the kubernetes api server in the ingress resource                                                                                                                                                                                                                                  | `kubernetes.{{config.rootDomain}}`                                          |
| `apiProxy.name`                                              | non-FQDN of kubernet4es api server in the ingress resource                                                                                                                                                                                                                                         | `kubernetes`                                                                |
| `authenticate.nameOverride`                                  | Name of the authenticate service.                                                                                                                                                                                                                                                                  | `authenticate`                                                              |
| `authenticate.fullnameOverride`                              | Full name of the authenticate service.                                                                                                                                                                                                                                                             | `authenticate`                                                              |
| `authenticate.redirectUrl`                                   | Redirect URL is the url the user will be redirected to following authentication with the third-party identity provider (IdP). [See more](https://www.pomerium.io/docs/reference/reference.html#redirect-url).                                                                                      | `https://{{authenticate.name}}.{{config.rootDomain}}/oauth2/callback`       |
| `authenticate.idp.provider`                                  | Identity [Provider Name](https://www.pomerium.io/docs/reference/reference.html#identity-provider-name).                                                                                                                                                                                            | `google`                                                                    |
| `authenticate.idp.clientID`                                  | Identity Provider oauth [client ID](https://www.pomerium.io/docs/reference/reference.html#identity-provider-client-id).                                                                                                                                                                            | Required                                                                    |
| `authenticate.idp.clientSecret`                              | Identity Provider oauth [client secret](https://www.pomerium.io/docs/reference/reference.html#identity-provider-client-secret).                                                                                                                                                                    | Required                                                                    |
| `authenticate.idp.url`                                       | Identity [Provider URL](https://www.pomerium.io/docs/reference/reference.html#identity-provider-url).                                                                                                                                                                                              | Optional                                                                    |
| `authenticate.idp.scopes`                                    | Identity [Provider Scopes](https://www.pomerium.io/configuration/#identity-provider-scopes).                                                                                                                                                                                                       | Optional                                                                    |
| `authenticate.idp.serviceAccount`                            | Identity Provider [service account](https://www.pomerium.io/docs/reference/reference.html#identity-provider-service-account) base64 encoded.                                                                                                                                                       | Optional                                                                    |
| `authenticate.idp.serviceAccountYAML`                        | Identity Provider [service account](https://www.pomerium.io/docs/reference/reference.html#identity-provider-service-account) as inline YAML or JSON.  <br><br>`authenticate.idp.serviceAccount` takes precedence.                                                                                  | Optional                                                                    |
| `authenticate.replicaCount`                                  | Number of Authenticate pods to run                                                                                                                                                                                                                                                                 | `1`                                                                         |
| `authenticate.autoscaling.enabled`                           | Enable Horizontal Pod Autoscaler for Authenticate pods                                                                                                                                                                                                                                             | false                                                                       |
| `authenticate.autoscaling.minReplicas`                       | Minimum number of pods in the Authenticate deployment                                                                                                                                                                                                                                              | `1`                                                                         |
| `authenticate.autoscaling.maxReplicas`                       | Maximum number of pods in the Authenticate deployment                                                                                                                                                                                                                                              | `5`                                                                         |
| `authenticate.autoscaling.targetCPUUtilizationPercentage`    | Target CPU utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                        | `50`                                                                        |
| `authenticate.autoscaling.targetMemoryUtilizationPercentage` | Target Memory utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                     | `50`                                                                        |
| `authenticate.pdb.enabled`                                   | Enable PodDisruptionBudget for Authenticate deployment                                                                                                                                                                                                                                             | false                                                                       |
| `authenticate.pdb.minAvailable`                              | Number of Authenticate pods that must be available, can be a number or percentage                                                                                                                                                                                                                  | `1`                                                                         |
| `authenticate.existingTLSSecret`                             | Name of existing TLS Secret for authenticate service                                                                                                                                                                                                                                               |                                                                             |
| `authenticate.deployment.annotations`                        | Annotations for the authenticate deployment. If none given, then use value of `annotations`                                                                                                                                                                                                        | `{}`                                                                        |
| `authenticate.deployment.extraEnv`                           | Set env variables on authenticate pods                                                                                                                                                                                                                                                             | `[]`                                                                        |
| `authenticate.service.annotations`                           | Annotations for the authenticate service. If none given, then use value of `service.annotations`                                                                                                                                                                                                   | `{}`                                                                        |
| `authentiate.serviceAccount.annotations`                     | Annotations for the authenticate service account                                                                                                                                                                                                                                                   | `{}`                                                                        |
| `authenticate.serviceAccount.nameOverride`                   | Override the name of the authenticate pod service account                                                                                                                                                                                                                                          | `pomerium-authenticate`                                                     |
| `authenticate.tls.cert`                                      | TLS certificate for authenticate service                                                                                                                                                                                                                                                           |                                                                             |
| `authenticate.tls.key`                                       | TLS key for authenticate service                                                                                                                                                                                                                                                                   |                                                                             |
| `authenticate.cacheServiceUrl`                               | The internally accesible url for the cache service.                                                                                                                                                                                                                                                | `https://{{cache.name}}.{{config.rootDomain}}`                              |
| `proxy.nameOverride`                                         | Name of the proxy service.                                                                                                                                                                                                                                                                         | `proxy`                                                                     |
| `proxy.fullnameOverride`                                     | Full name of the proxy service.                                                                                                                                                                                                                                                                    | `proxy`                                                                     |
| `proxy.authenticateServiceUrl`                               | The externally accessible url for the authenticate service.                                                                                                                                                                                                                                        | `https://{{authenticate.name}}.{{config.rootDomain}}`                       |
| `proxy.replicaCount`                                         | Number of Proxy pods to run                                                                                                                                                                                                                                                                        | `1`                                                                         |
| `proxy.autoscaling.enabled`                                  | Enable Horizontal Pod Autoscaler for Proxy pods                                                                                                                                                                                                                                                    | false                                                                       |
| `proxy.autoscaling.minReplicas`                              | Minimum number of pods in the Proxy deployment                                                                                                                                                                                                                                                     | `1`                                                                         |
| `proxy.autoscaling.maxReplicas`                              | Maximum number of pods in the Proxy deployment                                                                                                                                                                                                                                                     | `5`                                                                         |
| `proxy.autoscaling.targetCPUUtilizationPercentage`           | Target CPU utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                        | `50`                                                                        |
| `proxy.autoscaling.targetMemoryUtilizationPercentage`        | Target Memory utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                     | `50`                                                                        |
| `proxy.pdb.enabled`                                          | Enable PodDisruptionBudget for Proxy deployment                                                                                                                                                                                                                                                    | false                                                                       |
| `proxy.pdb.minAvailable`                                     | Number of Proxy pods that must be available, can be a number or percentage                                                                                                                                                                                                                         | `1`                                                                         |
| `proxy.existingTLSSecret`                                    | Name of existing TLS Secret for proxy service                                                                                                                                                                                                                                                      |                                                                             |
| `proxy.deployment.annotations`                               | Annotations for the proxy deployment. If none given, then use value of `annotations`                                                                                                                                                                                                               | `{}`                                                                        |
| `proxy.deployment.extraEnv`                                  | Set env variables on proxy pods                                                                                                                                                                                                                                                                    | `[]`                                                                        |
| `proxy.service.annotations`                                  | Annotations for the proxy service. If none given, then use value of `service.annotations`                                                                                                                                                                                                          | `{}`                                                                        |
| `proxy.serviceAccount.annotations`                           | Annotations for the proxy service account                                                                                                                                                                                                                                                          | `{}`                                                                        |
| `proxy.serviceAccount.nameOverride`                          | Override the name of the proxy pod service account                                                                                                                                                                                                                                                 | `pomerium-authenticate`                                                     |
| `proxy.tls.cert`                                             | TLS certificate for proxy service                                                                                                                                                                                                                                                                  |                                                                             |
| `proxy.tls.key`                                              | TLS key for proxy service                                                                                                                                                                                                                                                                          |                                                                             |
| `authorize.nameOverride`                                     | Name of the authorize service.                                                                                                                                                                                                                                                                     | `authorize`                                                                 |
| `authorize.fullnameOverride`                                 | Full name of the authorize service.                                                                                                                                                                                                                                                                | `authorize`                                                                 |
| `authorize.replicaCount`                                     | Number of Authorize pods to run                                                                                                                                                                                                                                                                    | `1`                                                                         |
| `authorize.autoscaling.enabled`                              | Enable Horizontal Pod Autoscaler for Authorize pods                                                                                                                                                                                                                                                | false                                                                       |
| `authorize.autoscaling.minReplicas`                          | Minimum number of pods in the Authorize deployment                                                                                                                                                                                                                                                 | `1`                                                                         |
| `authorize.autoscaling.maxReplicas`                          | Maximum number of pods in the Authorize deployment                                                                                                                                                                                                                                                 | `5`                                                                         |
| `authorize.autoscaling.targetCPUUtilizationPercentage`       | Target CPU utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                        | `50`                                                                        |
| `authorize.autoscaling.targetMemoryUtilizationPercentage`    | Target Memory utilization, averaged across pods (as a percent)                                                                                                                                                                                                                                     | `50`                                                                        |
| `authorize.pdb.enabled`                                      | Enable PodDisruptionBudget for Authorize deployment                                                                                                                                                                                                                                                | false                                                                       |
| `authorize.pdb.minAvailable`                                 | Number of Authorize pods that must be available, can be a number or percentage                                                                                                                                                                                                                     | `1`                                                                         |
| `authorize.existingTLSSecret`                                | Name of existing TLS Secret for authorize service                                                                                                                                                                                                                                                  |                                                                             |
| `forwardAuth.nameOverride`                                   | External name of the forward-auth endpoint                                                                                                                                                                                                                                                         | `forwardauth.${rootDomain}`                                                 |
| `forwardAuth.enabled`                                        | Enable forward-auth endpoint for third party ingress controllers to use for auth checks. Setting this disables automatic enumeration of `from` hostnames in the Pomerium Ingress object to prevent conflicts. Use `ingress.hosts` to mix forward-auth and proxy mode on a single Pomerium instance | `false`                                                                     |
| `forwardAuth.internal`                                       | If enabled no ingress is created for forwardAuth, making forwardAuth ony accessible as internal service.                                                                                                                                                                                           | `false`                                                                     |
| `authorize.deployment.annotations`                           | Annotations for the authorize deployment. If none given, then use value of `annotations`                                                                                                                                                                                                           | `{}`                                                                        |
| `authorize.deployment.extraEnv`                              | Set env variables on authorize pods                                                                                                                                                                                                                                                                | `[]`                                                                        |
| `authorize.service.annotations`                              | Annotations for the authorize service. If none given, then use value of `service.annotations`                                                                                                                                                                                                      | `{}`                                                                        |
| `authorize.serviceAccount.annotations`                       | Annotations for the authorize service account                                                                                                                                                                                                                                                      | `{}`                                                                        |
| `authorize.serviceAccount.nameOverride`                      | Override the name of the authorize pod service account                                                                                                                                                                                                                                             | `pomerium-authenticate`                                                     |
| `authorize.tls.cert`                                         | TLS certificate for authorize service                                                                                                                                                                                                                                                              |                                                                             |
| `authorize.tls.key`                                          | TLS key for authorize service                                                                                                                                                                                                                                                                      |                                                                             |
| `image.repository`                                           | Pomerium image                                                                                                                                                                                                                                                                                     | `pomerium/pomerium`                                                         |
| `image.tag`                                                  | Pomerium image tag                                                                                                                                                                                                                                                                                 | `v0.6.2`                                                                    |
| `image.pullPolicy`                                           | Pomerium image pull policy                                                                                                                                                                                                                                                                         | `IfNotPresent`                                                              |
| `service.annotations`                                        | Service annotations                                                                                                                                                                                                                                                                                | `{}`                                                                        |
| `service.externalPort`                                       | Pomerium's port                                                                                                                                                                                                                                                                                    | `443` if `config.insecure` is `false`.  `80` if `config.insecure` is `true` |
| `service.grpcTrafficPort.nameOverride`                       | Override name of grpc port in services.  Only use if required for protocol detection by mesh or ingress services                                                                                                                                                                                   | `https`/`grpc` in `secure`/`insecure` mode                                  |
| `service.httpTrafficPort.nameOverride`                       | Override name of http port in services.  Only use if required for protocol detection by mesh or ingress services.  Set to `http2` for istio when offloading mtls to the mesh.                                                                                                                      | `https`/`http` in `secure`/`insecure` mode                                  |
| `service.type`                                               | Service type (ClusterIP, NodePort or LoadBalancer)                                                                                                                                                                                                                                                 | `ClusterIP`                                                                 |
| `service.authorize.headless`                                 | Run Authorize service in Headless mode. Turn off if you **require** NodePort or LoadBalancer access to Authorize                                                                                                                                                                                   | `true`                                                                      |
| `serviceMonitor.enabled`                                     | Create Prometheus Operator ServiceMonitor                                                                                                                                                                                                                                                          | `false`                                                                     |
| `serviceMonitor.namespace`                                   | Namespace to create the ServiceMonitor resource in                                                                                                                                                                                                                                                 | The namespace of the chart                                                  |
| `serviceMonitor.labels`                                      | Additional labels to apply to the ServiceMonitor resource                                                                                                                                                                                                                                          | `release: prometheus`                                                       |
| `tracing.enabled`                                            | Enable distributed tracing                                                                                                                                                                                                                                                                         | `false`                                                                     |
| `tracing.debug`                                              | Set trace sampling to 100%. Use with caution!                                                                                                                                                                                                                                                      | `false`                                                                     |
| `tracing.provider`                                           | Specifies the tracing provider to configure (Valid options: Jaeger)                                                                                                                                                                                                                                | Required                                                                    |
| `tracing.jaeger.collector_endpoint`                          | The jaeger collector endpoint                                                                                                                                                                                                                                                                      | Required                                                                    |
| `tracing.jaeger.agent_endpoint`                              | The jaeger agent endpoint                                                                                                                                                                                                                                                                          | Required                                                                    |
| `ingress.enabled`                                            | Enables Ingress for pomerium                                                                                                                                                                                                                                                                       | `true`                                                                      |
| `ingress.annotations`                                        | Ingress annotations.  Ensure you set appropriate annotations for TLS backend and large URLs if using Azure.                                                                                                                                                                                        | `{}`                                                                        |
| `ingress.hosts`                                              | Ingress accepted hostnames                                                                                                                                                                                                                                                                         | `[]`                                                                        |
| `ingress.secretName`                                         | Ingress TLS certificate secret name                                                                                                                                                                                                                                                                | `[]`                                                                        |
| `ingress.tls.hosts`                                          | Override automatic ingress tls hosts list                                                                                                                                                                                                                                                          | `[]`                                                                        |
| `metrics.enabled`                                            | Enable prometheus metrics endpoint                                                                                                                                                                                                                                                                 | `false`                                                                     |
| `metrics.port`                                               | Prometheus metrics endpoint port                                                                                                                                                                                                                                                                   | `9090`                                                                      |
| `cache.deployment.extraEnv`                                  | Set env variables on cache pods                                                                                                                                                                                                                                                                    | `[]`                                                                        |
| `cache.nameOverride`                                         | Name of the cache service.                                                                                                                                                                                                                                                                         | `cache`                                                                     |
| `cache.fullnameOverride`                                     | Full name of the cache service.                                                                                                                                                                                                                                                                    | `cache`                                                                     |
| `cache.replicaCount`                                         | Number of cache pods to run                                                                                                                                                                                                                                                                        | `1`                                                                         |
| `cache.pdb.enabled`                                          | Enable PodDisruptionBudget for Cache deployment                                                                                                                                                                                                                                                    | false                                                                       |
| `cache.pdb.minAvailable`                                     | Number of pods that must be available, can be a number or percentage                                                                                                                                                                                                                               | `1`                                                                         |
| `cache.serviceAccount.annotations`                           | Annotations for the cache service account                                                                                                                                                                                                                                                          | `{}`                                                                        |
| `cache.serviceAccount.nameOverride`                          | Override the name of the cache pod service account                                                                                                                                                                                                                                                 | `pomerium-authenticate`                                                     |
| `cache.tls.cert`                                             | TLS certificate for cache service                                                                                                                                                                                                                                                                  |                                                                             |
| `cache.tls.key`                                              | TLS key for cache service                                                                                                                                                                                                                                                                          |                                                                             |
| `cache.existingTLSSecret`                                    | Name of existing TLS Secret for authorize service                                                                                                                                                                                                                                                  |                                                                             |
| `operator.enabled`                                           | Enable experimental pomerium operator support                                                                                                                                                                                                                                                      | false                                                                       |
| `operator.nameOverride`                                      | Name of the operator                                                                                                                                                                                                                                                                               | `operator`                                                                  |
| `operator.fullnameOverride`                                  | Full name of the operator                                                                                                                                                                                                                                                                          | `operator`                                                                  |
| `operator.replicaCount`                                      | Number of operator pods to run                                                                                                                                                                                                                                                                     | `1`                                                                         |
| `operator.image.repository`                                  | Pomerium Operator image                                                                                                                                                                                                                                                                            | `pomerium/pomerium-operator`                                                |
| `operator.image.tag`                                         | Pomerium Operator image tag                                                                                                                                                                                                                                                                        | `v0.0.1-rc1`                                                                |
| `operator.config.ingressClass`                               | `kubernetes.io/ingress.class` for the operator to monitor                                                                                                                                                                                                                                          | `pomerium`                                                                  |
| `operator.config.serviceClass`                               | `kubernetes.io/service.class` for the operator to monitor                                                                                                                                                                                                                                          | `pomerium`                                                                  |
| `operator.config.debug`                                      | Enable Pomerium Operator debug logging                                                                                                                                                                                                                                                             | `false`                                                                     |
| `operator.deployment.annotations`                            | Annotations for the operator deployment.                                                                                                                                                                                                                                                           | `{}`                                                                        |
| `redis.cluster.slaveCount`                                   | Number of slave replicas to run. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                                                    | `1`                                                                         |
| `redis.enabled`                                              | Enable a redis master-slave subchart deployment based on https://github.com/bitnami/charts/tree/master/bitnami/redis                                                                                                                                                                               | `false`                                                                     |
| `redis.existingSecret`                                       | Secret used to store authentication password for redis.  This is shared between Pomerium and redis.  [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                | `pomerium-redis-password`                                                   |
| `redis.existingSecretPasswordKey`                            | Name of key containing password in `redis.existingSecret`. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                          | `password`                                                                  |
| `redis.forceGenerateTLS`                                     | Force re-generation of TLS certificates used to communicate with redis                                                                                                                                                                                                                             | `false`                                                                     |
| `redis.generateTLS`                                          | Automatically generate a new CA and certificate pair to communicate with redis                                                                                                                                                                                                                     | `true`                                                                      |
| `redis.tls.certCAFilename`                                   | Name of secret key containing CA certificate for verify TLS certificates. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                           | `ca.crt`                                                                    |
| `redis.tls.certFilename`                                     | Name of secret key containing certificate for TLS connections. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                      | `tls.crt`                                                                   |
| `redis.tls.certificateSecret`                                | Name of secret containing TLS CA, certificate and private key. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                      | `pomerium-redis-tls`                                                        |
| `redis.tls.certKeyFilename`                                  | Name of secret key containing private key for TLS connections. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                      | `tls.key`                                                                   |
| `redis.tls.enabled`                                          | Require TLS communication with redis. [More](https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)                                                                                                                                                                               | `true`                                                                      |

[randAscii]: http://masterminds.github.io/sprig/strings.html#randalphanum-randalpha-randnumeric-and-randascii

## Changelog

### 14.0.0

- `SHARED_SECRET` and `COOKIE_SECRET` are now defined via environment variables in a separate secret from the one containing `config.yaml`, are read back from the cluster (if auto-generated instead of being defined in config.yaml), and used to derive a password for connecting to Redis (when enabled). 
- When non-memory (ie. Redis) databroker storage is enabled, `DATABROKER_STORAGE_CONNECTION_STRING `and `DATABROKER_STORAGE_TLS_SKIP_VERIFY` are now defined via environment variables in a separate secret from the one containing `config.yaml`.

See [v14.0.0 Upgrade Nodes](#1400-1) to migrate.

### 13.0.0

- `config.existingSigningKeySecret` updated to have correct camelCase. Additionally uses of `authorize.existingsigningKeySecret` and `authorize.signingKey` have been updated to the correct `config.` block. See [v13.0.0 Upgrade Nodes](#1300-1) to migrate.

### 11.0.0

- Signing key has been refactored to correspond with Pomerium changes. See [v11.0.0 Upgrade Nodes](#1100-1) to migrate.

### 10.2.0

- Update port names in insecure mode to address Istio protocol detection.  

### 10.0.0

- Refactor shared configuration logic to be driven by named templates. See [v10.0.0 Upgrade Nodes](#1000-1) to migrate.

### 8.5.5

- Fix: Set not only the service but also the namespace when `forwardAuth.internal == true`

### 8.5.1

- Add documentation for `extraOpts` flag, remove `policyFile` flag as it isn't implemented.

### 8.5.0

- Add `forwardAuth.internal` flag to not expose forwardAuth over ingress. Useful for cases where the ingress should not set trustedIPs.

### 8.4.0

- Add `config.insecure` flag in order to support running Pomerium in non-tls mode to play well with reverse proxy's like Istio's envoy

### 8.0.0

- Pomerium `ConfigMap` and `Secret` were combined into a single `Secret`. See [v8.0.0 Upgrade Nodes](#800-1) to migrate

### 7.0.0

- Add automatic signing key generation.  See [v7.0.0 Upgrade Nodes](#700-1) to migrate

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

### 14.0.0

- `SHARED_SECRET` and `COOKIE_SECRET` are now set via environment variables, in a separate secret from the one containing `config.yaml`.
  - If you are defining these variables outside of `config.sharedSecret` and `config.cookieSecret` (ie. in `extraEnv` or `extraEnvFrom`), ensure that `config.generateSharedSecrets` is set to `false`.
    - If you are using Redis, make sure that you set either `redis.password` or the `redis.existingSecretPasswordKey` in the secret defined by `redis.existingSecret`.
- When a non-memory databroker storage type (ie. Redis) is enabled, `DATABROKER_STORAGE_CONNECTION_STRING` and `DATABROKER_STORAGE_TLS_SKIP_VERIFY` are defined in the cache deployment as environment variables via a separate secret.
  - If you are defining these variables outside of `databroker.storage.connectionString` and `databroker.storage.tlsSkipVerify` (ie. in `cache.deployment.extraEnv` or `extraEnvFrom`), ensure that `databroker.storage.autoconfigure` is set to `false`.
- When `redis.enabled` was set to `true` and `config.sharedSecret` was undefined, the previous version of this chart would generate a random ASCII value for `redis.password` that [usually contained URL-invalid characters][bug 167].
  - If your release contains a `pomerium-redis-password` Secret with a non-hexadecimal value for `password`, you should delete it, so that a valid password derived from the (autogenerated) shared secret can be generated instead.

[bug 167]: https://github.com/pomerium/pomerium-helm/issues/167

### 13.0.0

- `existingsigningKeySecret` has been corrected to `existingSigningKeySecret` and properly standardized to the `config` block in all use cases.
  - If you were specifying `config.existingsigningKeySecret`, update the value to the correct casing.
  - If you were using `authorize.existingsigningKeySecret` and `authorize.signingKey` to create a signing key with the value from `config.signingKey` there should not be an impact, but the deprecated values can be removed.

### 12.3.0

- If using the new `redis` support and you wish to use the automatic tls generation, set `redis.forceGenerateTLS` to ensure the new secrets are generated.  After the upgrade is complete, you should set `redis.forceGenerateTLS` to `false` (the default) again.

### 11.0.0

- SigningKey is now under the `config` block.  
  - If you are specifying `proxy.signingKeySecret` or `proxy.existingSigningKeySecret`, please change the values to be `config.signingKeySecret` or `config.existingSigningKeySecret`
  - If were relying on automatic signing key generation do one of the following:
    1. set `config.forceGenerateSigningKey` to `true` for the upgrade
    2. replace [RELEASE NAME] with your release name and run: 
      ```
      kubectl get secret [RELEASE NAME]-proxy-signing-key -o json | jq '. | .metadata.name = (.metadata.name | sub("(?<x>\\w+)-proxy-signing-key";"\(.x)-signing-key") )' | kubectl apply -f - 
      ``` 

### 10.0.0

- All shared configuration has been moved from ENV vars to a configuration file.  Users of `config.existingSecret` must specify **all** parameters in their secret or leverage `extraEnv` to pass in overrides.  
  
  Some of the impacted chart values and their equivilent settings are listed below:

  | Chart Value                    | Config Parameter                    |
  | ------------------------------ | ----------------------------------- |
  | `authenticate.idp.provider`    | `idp_provider`                      |
  | `authenticate.idp.url`         | `idp_provider_url`                  |
  | `authenticate.cacheServiceUrl` | `cache_service_url`                 |
  | `authenticate.idp.scopes`      | `idp_scopes`                        |
  | `config.insecure`              | `insecure_server` + `grpc_insecure` |
  | `proxy.authenticateServiceUrl` | `authenticate_service_url`          |
  | `proxy.authorizeInternalUrl`   | `authorize_service_url`             |

  Other settings required in your `config.existingSecret` or `extraEnv`:

  - `CACHE_SERVICE_URL=[your cache service url]`
  - `AUTHENTICATE_SERVICE_URL=[your authenticate service url]`
  - `CERTIFICATE_FILE="/pomerium/cert.pem"`
  - `CERTIFICATE_KEY_FILE="/pomerium/privkey.pem"`
  - `CERTIFICATE_AUTHORITY_FILE="/pomerium/ca.pem"`

  If you are not using `config.existingSecret` you should not need to make any changes.

### 8.0.0

- `config.existingConfig` `ConfigMap` has been merged with `config.existingSecret` `Secret`. All keys from `config.existingConfig` were moved to the `config.existingSecret`
- `config.existingSecret` structure has been changed:

  - all top level keys were moved under the `config.yaml` section
  - naming of the top level keys was changed from `cookie-secret` to `cookie_secret` according to [the `config.yaml` format](https://www.pomerium.io/configuration/#shared-settings) (basically `'-'` was changed to the `'_'`)

- `config.existingConfig` and `config.existingSecret` cannot be used separately anymore
- If `config.existingConfig` and `config.existingSecret` options weren't used no actions are required

### 7.0.0

- A signing key is now automatically generated, similar to TLS secrets.
  - If upgrading an install you should temporarily set `config.forceGenerateSigningKey` to `true` and generate this key during upgrade.

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
