# Ingress via Tailscale

Exposes services inside AKS over the Tailscale network, making them available as Tailscale machines. 

1. Install the operator https://tailscale.com/kb/1236/kubernetes-operator#setup

Annotate services to expose them via Tailnet machinesL

```yaml
apiVersion: v1
kind: Service
metadata:
  name: seq-service
  namespace: seq
  labels:
    app: seq
  annotations:
    tailscale.com/expose: "true"
    tailscale.com/hostname: seq-aks
spec:
  selector:
    app: seq
  type: ClusterIP
  ports:
    - port: 5341
      targetPort: 80
      name: web
```