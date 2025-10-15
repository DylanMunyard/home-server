# Cloud-Ctrl Cost Monitoring

This folder contains the Kubernetes CronJob configuration for exporting metrics to CloudCtrl for cost monitoring.

## Prerequisites

Before deploying the cost monitoring CronJob, you need to create a Kubernetes secret containing the CloudCtrl API key. Instructions [docs.cloudctrl/Kubernetes/#metrics-agent](https://docs.cloudctrl.com.au/Kubernetes/#metrics-agent)

### Create the Secret

Run the following command to create the secret in the `monitoring` namespace:

```bash
kubectl create secret generic cloudctrl-credentials \
  --from-literal=api-key=API_KEY \
  -n monitoring
```

Replace `API_KEY` with your actual CloudCtrl API key.

## Deployment

After creating the secret, apply the CronJob configuration:

```bash
kubectl apply -f costmonitoring.yaml
```

## Configuration

The CronJob runs every 8 hours and exports metrics from the Prometheus instance to CloudCtrl for cost analysis and monitoring.

### Environment Variables

- `CloudCtrl__ClusterName`: The name of your AKS cluster
- `CloudCtrl__ApiKey`: API key for CloudCtrl (stored in secret)
- `CloudCtrl__TenantId`: Your CloudCtrl tenant ID
- `CloudCtrl__CloudAccountId`: Your cloud account ID
- `Metrics__Host`: Prometheus service hostname
- `Metrics__Port`: Prometheus service port

