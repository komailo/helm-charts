## Bootstrap

```sh
CLUSTER_NAME=
ACCESS_KEY=
ACCESS_KEY_SECRET=
echo -n "$ACCESS_KEY" > ./access-key
echo -n "$ACCESS_KEY_SECRET" > ./secret-access-key
kubectl create secret generic aws-iam-user-k8s-$CLUSTER_NAME --from-file=./access-key --from-file=./secret-access-key -n external-secrets
```

For AVP:

```sh
ACCESS_KEY=
ACCESS_KEY_SECRET=
echo -n "$ACCESS_KEY" > ./access-key
echo -n "$ACCESS_KEY_SECRET" > ./secret-access-key
kubectl create secret generic aws-iam-user-k8s-ott-1-argocd-avp --from-file=./access-key --from-file=./secret-access-key -n argocd
```
