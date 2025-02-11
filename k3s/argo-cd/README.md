# Argo CD
Install Argo CD https://argo-cd.readthedocs.io/en/stable/getting_started/
- Then apply [argocd-cmd-params-cm.yaml](./argocd-cmd-params-cm.yaml)
- Then [argocd-cm.yaml](./argocd-cm.yaml)

Then bounce the pod

Create apps, and scope the path to a sub-folder to deploy just that app. 