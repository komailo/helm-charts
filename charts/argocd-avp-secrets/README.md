## Bootstrap

```sh
ACCESS_KEY=
ACCESS_KEY_SECRET=
echo -n "$ACCESS_KEY" > ./access-key
echo -n "$ACCESS_KEY_SECRET" > ./secret-access-key
kubectl create secret generic aws-ssm-parameter-store-argocd-avp --from-file=./access-key --from-file=./secret-access-key -n avp-secrets
```
