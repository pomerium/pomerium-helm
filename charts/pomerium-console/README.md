# pomerium-console

![Version: 8.0.0](https://img.shields.io/badge/Version-8.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.17.0](https://img.shields.io/badge/AppVersion-0.17.0-informational?style=flat-square)

Pomerium Enterprise Console

**Homepage:** <https://www.pomerium.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Pomerium Developers |  | https://www.pomerium.com |

Installation
-------------

pomerium-console requires the shared secret of your existing databroker and a supported RDBMS backend to install.

```bash
helm install pomerium-enterprise/pomerium-console \
    --set database.type=pg \
    --set database.username=pomerium \
    --set database.password=strongpassword \
    --set database.host=pghost.local \
    --set database.name=pomerium-console \
    --set config.sharedSecret=ZGVhZGJlZWZkZWFkYmVlZmRlYWRiZWVmCg== \
    --set config.databaseEncryptionKey=hDiBsQ6MJFr2y9jhT6c2Uu3lHw9/IpULfBJyesjPWpE= \
    --set config.authenticateServiceUrl=https://authenticate.localhost.pomerium.io \
    --set config.audience=console.localhost.pomerium.io \
    --set config.licenseKey=XXXXXXXXXXXXXXXXX
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Specify node `affinity` for the deployment |
| autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaler |
| autoscaling.maxReplicas | int | `3` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| config.administrators | string | `""` | Set to boostrap permissions to the console or recover from a misconfiguration.  Overrides permissions in the database. |
| config.audience | string | `""` | **Required** console's external URL.  This should match the `from` in Pomerium Core's config. |
| config.authenticateServiceUrl | string | `""` | **Required** for device identity enrollment.  If set, you do not need to set signingKey. |
| config.customerId | string | `""` | Override default customerId |
| config.databaseEncryptionKey | string | `""` | **Required** encryption key for protecting sensitive data in the database |
| config.databrokerServiceUrl | string | `https://pomerium-databroker.[release namespace].svc.cluster.local` | Override the URL default to the Pomerium Cache service |
| config.licenseKey | string | `""` | **Required** license key for your Pomerium Enterprise install. |
| config.prometheusUrl | string | `""` | Set URL for external prometheus server.  An embedded server is used if left unset. |
| config.sharedSecret | string | `""` | **Required** Secures communication with the databroker.  Must match Pomerium `shared_secret` parameter. |
| config.signingKey | string | `""` | **Required** if `config.authenticateServiceUrl` is unset.  Set the public key for verifying the Pomerium attestation JWT header |
| database.additionalDSNOptions | string | `""` | Set custom DSN connection options |
| database.host | string | `""` | Set the database hostname |
| database.name | string | `""` | Set the name of the database or schema |
| database.password | string | `""` | Set the database password |
| database.sslmode | string | `""` | Set appropriately for your database driver |
| database.tls.ca | string | `""` | A custom CA certificate when communicating with the database |
| database.tls.caSecretKey | string | `"tls.crt"` | Set the key name containing the CA certificate in the existingCASecret |
| database.tls.cert | string | `""` | Set a TLS client certificate for the database connection |
| database.tls.existingCASecret | string | `""` | Use an existing secret containing the CA certificate for the database connection |
| database.tls.existingSecret | string | `""` | Use an existing secret containing the client TLS keypair for the database connection |
| database.tls.key | string | `""` | Set a TLS client key for the database connection |
| database.type | string | `""` | **Required** Set database driver type.  This can be `pg`, `my` or sqlite for postgres, mysql or sqlite respectively |
| database.username | string | `""` | Set the database username |
| fullnameOverride | string | `""` | Override full release name |
| image.pullPassword | string | `""` | Set to automatically generate an image pull secret |
| image.pullPolicy | string | `"IfNotPresent"` | The iamge pull policy |
| image.pullUsername | string | `""` | Set to automatically generate an image pull secret |
| image.repository | string | `"docker.cloudsmith.io/pomerium/enterprise/pomerium-console"` | The image repository source |
| image.tag | string | `""` | Override the image tag from the chart appVersion |
| imagePullSecrets | list | `[]` | Reference a list secrets containing image pull credentials for the deployment |
| ingress.annotations | object | `{}` | Set custom annoations on the Ingress resource |
| ingress.enabled | bool | `false` | Enable an Ingress resource for the deployment.  This should be disabled unless your Pomerium core deployment is running outside the cluster. |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` | Set a list of Ingress TLS secrets |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Specify node `selector` parameters for the deployment |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":false,"finalizers":["kubernetes.io/pvc-protection"],"size":"1Gi"}` | FOR TESTING ONLY.  There is no migration path from embedded (sqlite) to an external RDBMS. |
| persistence.enabled | bool | `false` | Enable a PVC for the embedded database engine |
| podAnnotations | object | `{}` | Set annotations on all pods |
| podSecurityContext | object | `{}` | Set security context on all pods |
| prometheus.enabled | bool | `true` | Enable using an embedded prometheus service if no external URL is provided |
| prometheus.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| prometheus.persistence.annotations | object | `{}` |  |
| prometheus.persistence.enabled | bool | `false` | Enable storage persistence for embedded prometheus |
| prometheus.persistence.existingClaim | string | `""` |  |
| prometheus.persistence.finalizers[0] | string | `"kubernetes.io/pvc-protection"` |  |
| prometheus.persistence.size | string | `"10Gi"` |  |
| prometheus.persistence.storageClassName | string | `""` |  |
| replicaCount | int | `1` | Sets the number of pod replicas deployed |
| resources | object | `{"requests":{"cpu":"500m","memory":"500Mi"}}` | Specify the kubernetes resources for the pods.  Minimal `requests` have been set and should be adjusted for your environment. |
| securityContext | object | `{}` | Set security context on all containers |
| service.type | string | `"ClusterIP"` | Set service type.  This should be ClusterIP unless your Pomerium Core deployment is running on a separate cluster. |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tls.ca | string | `""` | A custom CA certificate when communicating with Pomerium Core |
| tls.caSecretKey | string | `"tls.crt"` | Set the key name containing the CA certificate in the existingCASecret |
| tls.cert | string | `""` | TLS server cert |
| tls.enabled | bool | `true` | Enable TLS server support (strongly recommended) |
| tls.existingCASecret | string | `""` | Use an existing secret for a CA certificate when communicating with Pomerium Core |
| tls.existingSecret | string | `""` | Use an existing secret for TLS certificates |
| tls.forceGenerate | bool | `false` | Regenerate certificates.  Enable if you need to recreate your certificates after initial chart install, or want to enable `tls.generate` after the chart has already been installed. |
| tls.generate | bool | `true` | Automatically generate a CA and certificates for TLS termination when chart is initially installed. |
| tls.key | string | `""` | TLS server key |
| tolerations | list | `[]` | Specify node `tolerations` for the deployment |
