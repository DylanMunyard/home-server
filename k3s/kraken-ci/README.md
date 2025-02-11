# Kraken CI
Install Kraken CI (A build server) https://kraken.ci/docs/install-helm

We need to patch the Helm YAML to add a node selector so that their pods are deployed on Proxmox host node.  \
This was necessary due to some of their containers incompatible with arm64

- Followed https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/#kustomizing-helm-charts
- `argocd-cm` is here [argocd-cm](../argo-cd//argocd-cm.yaml)
