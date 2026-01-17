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

## DotEnv Secrets

Use `DotEnvSecrets` when a single AWS SSM parameter stores multiple values in an `.env` style format (`KEY=VALUE` per line). The chart reads the parameter once and splits each line into a separate key in the generated `Secret`.

```yaml
DotEnvSecrets:
  - name: app-env
    remoteRefKey: /env/app
```

Lines without an `=` or beginning with `#` are skipped. Keys keep their original casing (`foo=BaR` stays `foo`).
