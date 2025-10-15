# Prometheus Stack for AKS

This directory contains the configuration for deploying a complete observability stack on AKS using **Helm charts** including:
- **Prometheus Operator**: Manages Prometheus instances and related monitoring components
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards (exposed via Tailscale)
- **Loki**: Log aggregation and querying
- **Tempo**: Distributed tracing

## Prerequisites

1. **Helm 3**: Install Helm on your local machine
2. **Tailscale Operator**: Must be installed and configured in your AKS cluster for Grafana exposure
3. **Storage Classes**: Ensure your AKS cluster has a default storage class for persistent volumes
4. **kubectl**: Configured to access your AKS cluster

## Quick Start

**Fresh Installation:**
```bash
./install.sh
```

**Clean Reinstall (if you have existing deployment):**
```bash
./uninstall.sh  # Removes everything including data
./install.sh    # Fresh install with shared storage
```

## Installation Steps (Helm Method - Recommended)

### 1. Add Helm Repositories

```bash
# Add the required Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 2. Create Namespace and Shared Storage

```bash
# Create the monitoring namespace
kubectl create namespace monitoring

# Create shared storage PVC (cost optimization for single-node)
kubectl apply -f shared-storage.yaml
```

### 3. Install Prometheus Stack (Prometheus + Grafana + Alertmanager)

```bash
# Install the complete Prometheus stack with Grafana
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values-prometheus-stack.yaml \
  --wait
```

### 4. Install Loki

```bash
# Install Loki for log aggregation
helm install loki grafana/loki \
  --namespace monitoring \
  --values values-loki.yaml \
  --wait
```

### 5. Install Tempo

```bash
# Install Tempo for distributed tracing
helm install tempo grafana/tempo \
  --namespace monitoring \
  --values values-tempo.yaml \
  --wait
```

### 6. Update Grafana Data Sources (Optional)

The Grafana instance will be automatically configured with Prometheus. To add Loki and Tempo data sources, you can either:

**Option A: Update via Helm values and upgrade**
```bash
# After Loki and Tempo are running, upgrade Grafana with updated data sources
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values-prometheus-stack.yaml \
  --wait
```

**Option B: Add manually via Grafana UI**
- Access Grafana via Tailscale at `grafana-aks`
- Go to Configuration > Data Sources
- Add Loki: `http://loki-gateway.monitoring.svc.cluster.local`
- Add Tempo: `http://tempo.monitoring.svc.cluster.local:3100`

## Alternative: Manual YAML Installation

If you prefer the manual approach, the individual YAML files are still available. See the "Manual Installation" section below.

## Verification

Check that all components are running:

```bash
# Check all pods in monitoring namespace
kubectl get pods -n monitoring

# Check Helm releases
helm list -n monitoring

# Check services
kubectl get services -n monitoring

# Check Prometheus targets (should show discovered services)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Then visit http://localhost:9090/targets

# Check Grafana is accessible via Tailscale
# The service should appear as 'grafana-aks' in your Tailscale network
```

## Helm Management

```bash
# Upgrade a release with new values
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values-prometheus-stack.yaml

# Clean uninstall (removes everything including data)
./uninstall.sh

# Check release status
helm status kube-prometheus-stack -n monitoring
helm list -n monitoring
```

## Access

- **Grafana**: Available via Tailscale at `grafana-aks` (configured with Tailscale annotations)
- **Prometheus**: Internal cluster access only (port-forward for debugging: `kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090`)
- **Loki**: Internal cluster access only (port-forward for debugging: `kubectl port-forward -n monitoring svc/loki-gateway 80:80`)
- **Tempo**: Internal cluster access only (port-forward for debugging: `kubectl port-forward -n monitoring svc/tempo 3100:3100`)

## Default Credentials

- **Grafana**: admin/admin (change on first login)

## Data Sources

Grafana will be pre-configured with:
- **Prometheus**: `http://prometheus-service.monitoring.svc.cluster.local:9090`
- **Loki**: `http://loki-service.monitoring.svc.cluster.local:3100`
- **Tempo**: `http://tempo-service.monitoring.svc.cluster.local:3200`

## Storage (Cost-Optimized Shared Approach)

**Single Shared Disk**: 100Gi total storage shared across all components:
- **Prometheus**: `/prometheus-data` subpath (metrics storage, 30 day retention)
- **Grafana**: `/grafana-data` subpath (dashboards and configuration)
- **Loki**: `/loki-data` subpath (log storage)
- **Tempo**: `/tempo-data` subpath (trace storage)
- **Alertmanager**: `/alertmanager-data` subpath (alert state)

This approach uses a single Azure disk instead of 4-5 separate disks, significantly reducing storage costs for single-node deployments.

## Troubleshooting

### Common Issues

1. **CRDs not installed**: Ensure all CRDs are installed before deploying the operator
2. **Storage issues**: Verify your AKS cluster has a default storage class
3. **Tailscale not working**: Ensure Tailscale operator is properly configured
4. **Pods stuck in pending**: Check resource requests and node capacity

### Useful Commands

```bash
# Check operator logs
kubectl logs -n monitoring deployment/prometheus-operator

# Check Prometheus configuration
kubectl get prometheus -n monitoring -o yaml

# Check ServiceMonitor discovery
kubectl get servicemonitors -n monitoring

# Debug Grafana
kubectl logs -n monitoring deployment/grafana
```
