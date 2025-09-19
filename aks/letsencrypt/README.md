# Issue dem certs 
Deploy a Certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: bf42-stats-cert
  namespace: bf42-stats
spec:
  secretName: bf42-stats-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - staging.bfstats.io
```