# helm-charts

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/komailo/helm-charts/badge)](https://scorecard.dev/viewer/?uri=github.com/komailo/helm-charts)

Hey there! These are the Helm charts I use with ArgoCD on my personal Kubernetes cluster.

These charts were published into the open source realm for inspiration and may not be usable directly. In many cases these charts sub charts the offical Helm chart and provides values and templating on top of that.

## Story beind the initial commit history

If you are one of those people who like to look at the commit history to see how something was developed, you might notice that the commit history does not represent the actual timeline it would have taken to develop all these charts.

When I first started with these charts, I was putting secrets in everywhere. The goal was speed vs correctness. Now with Argo Vault Plugin in place I can have in line secrets replaced during deployment time and the charts were updated to use AVP where needed. All the secrets were rotated as well but to be extra cautious a new Git repository was created, and all the files were copied and commited. This cleaned the Git history and no secrets were to be found.
