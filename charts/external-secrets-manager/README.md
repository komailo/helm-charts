# External Secrets Manager

This chart allows parent charts to create external secrets.

## Configuration & Feature Flags

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `globals.secretStoreRefKind` | string | `ClusterSecretStore` | Default SecretStore kind |
| `globals.secretStoreRefName` | string | `aws-ssm-parameter-store-default` | Default SecretStore name |
| `globals.refreshInterval` | string | `24h` | Default interval to refresh secrets |
| `SimpleSecrets[].name` | string | `""` | Name of the ExternalSecret and target Secret |
| `SimpleSecrets[].namespace` | string | `""` | Target namespace (defaults to release namespace) |
| `SimpleSecrets[].targetName` | string | `""` | Target Secret name (defaults to `name`) |
| `SimpleSecrets[].dataSecretKey` | string | `""` | Key in the Kubernetes Secret |
| `SimpleSecrets[].remoteRefKey` | string | `""` | Key/path in the remote secret store |
| `SimpleSecrets[].type` | string | `""` | (Optional) Kubernetes Secret type (e.g. `kubernetes.io/dockerconfigjson`). Omitted if not defined. |
| `SubPathSecrets[].name` | string | `""` | Name of the ExternalSecret and target Secret |
| `SubPathSecrets[].remoteRefKey` | string | `""` | Path in remote store to search recursively |
| `SubPathSecrets[].type` | string | `""` | (Optional) Kubernetes Secret type. Omitted if not defined. |
| `JsonSecrets[].name` | string | `""` | Name of the ExternalSecret and target Secret |
| `JsonSecrets[].remoteRefKey` | string | `""` | Key in remote store containing JSON object |
| `JsonSecrets[].type` | string | `""` | (Optional) Kubernetes Secret type. Omitted if not defined. |

## Simple Secrets

To create a simple secret referencing an external secret, use the following example and place it in your values file. You can optionally set `type` (for example, `kubernetes.io/dockerconfigjson` for image pull secrets):

```yaml
SimpleSecrets:
  - name: test-secret
    dataSecretKey: mySecret
    remoteRefKey: /my-path/test-secret
  - name: ghcr-pull-secret
    dataSecretKey: .dockerconfigjson
    remoteRefKey: /k8s-prod/pull-secrets/ghcr
    type: kubernetes.io/dockerconfigjson
```

## JSON Secrets

`JsonSecrets` expects the upstream value to be a JSON object (string) where each entry maps directly to the resulting Kubernetes `Secret` data. This follows the [External Secrets Operator "all keys" guide](https://external-secrets.io/latest/guides/all-keys-one-secret/).

Store the SSM parameter value similar to:

```json
{"MONGO_INITDB_ROOT_USERNAME":"root","MONGO_INITDB_ROOT_PASSWORD":"example"}
```

and reference it in the chart:

```yaml
JsonSecrets:
  - name: app-env
    remoteRefKey: /env/app
```

Every JSON key is copied verbatim into the generated `Secret` and values remain as plain strings.
