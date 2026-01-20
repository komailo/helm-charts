# External Secrets Manager

This chart allows parent charts to create external secrets.

## Simple Secrets

To create a simple secret type referencing an external secret use the following example and place it in your values file.

```yaml
SimpleSecrets:
  - name: test-secret
    dataSecretKey: mySecret
    remoteRefKey: /my-path/test-secret
  - name: foo
    dataSecretKey: mySecret
    remoteRefKey: /my-path/test-secret-2
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
