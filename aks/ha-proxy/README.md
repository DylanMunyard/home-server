# Ingress via Cloudflare tunnel

Create a tunnel

```bash
# Install cloudflared locally
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64

# Login to Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create aks-tunnel

# Note the Tunnel ID and credentials file location
```

Create the Kube secret from tunnel credentials

```bash
kubectl create ns cloudflared
kubectl create secret generic tunnel-credentials \
  --from-file=credentials.json=/home/dylan/.cloudflared/70d35215-771d-4e6e-a220-cf113b0fb1ae.json --namespace cloudflared
```

Apply [cloudflared-tunnel.yml](./cloudflared-tunnel.yml)

Route DNS via the tunnel

```bash
cloudflared tunnel route dns aks-tunnel bfstats.io
cloudflared tunnel route dns aks-tunnel staging.bfstats.io
```