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
