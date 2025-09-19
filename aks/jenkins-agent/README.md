# Run Jenkins agent jobs in AKS

```bash
# Create service account in jenkins-ci namespace                                                                                                                                                    5.76% 9/67GB 
kubectl create serviceaccount jenkins-sa -n jenkins-ci

# Create cluster role binding (cluster-wide permissions)
kubectl create clusterrolebinding jenkins-sa-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=jenkins-ci:jenkins-sa

# Create long-lived token secret in jenkins-ci namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-sa-token
  namespace: jenkins-ci
  annotations:
    kubernetes.io/service-account.name: jenkins-sa
type: kubernetes.io/service-account-token
EOF

# Get the token
kubectl get secret jenkins-sa-token -n jenkins-ci -o jsonpath='{.data.token}' | base64 -d
```

Create a new 'Cloud' in Jenkins > Manage Jenkins > Clouds> + New Cloud
- Put the JWT in the 'Secret text' of the credential
- Grab the API server certificate and paste it in the `Kubernetes server certificate key`
```bash
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d
```
