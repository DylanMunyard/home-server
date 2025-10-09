#!/bin/bash
# Quick installation script for the complete observability stack

set -e

echo "🚀 Installing Complete Observability Stack on AKS"
echo "=================================================="

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm 3 first."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo "✅ Helm repositories added"

# Create namespace
echo "🏗️  Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespace created"

# Create shared storage PVCs
echo "💾 Creating shared storage..."
kubectl apply -f shared-storage.yaml
kubectl apply -f azure-disk-storage.yaml
echo "✅ Storage PVCs created"

# Setup directory permissions on hostPath (for Loki only)
echo "🔧 Setting up directory permissions for Loki..."
kubectl apply -f setup-permissions-job.yaml
echo "   Waiting for permissions setup to complete..."
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/setup-monitoring-permissions -n monitoring --timeout=60s 2>/dev/null || true
kubectl logs setup-monitoring-permissions -n monitoring 2>/dev/null || echo "   Setup logs not available yet"
kubectl delete pod setup-monitoring-permissions -n monitoring --ignore-not-found=true
echo "✅ Directory permissions configured"

# Install Prometheus Stack
echo "📊 Installing Prometheus Stack (Prometheus + Grafana + Alertmanager)..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values-prometheus-stack.yaml \
  --timeout 15m
echo "✅ Prometheus Stack deployment initiated"

# Install Loki
echo "📝 Installing Loki..."
helm upgrade --install loki grafana/loki \
  --namespace monitoring \
  --values values-loki.yaml \
  --timeout 10m
echo "✅ Loki deployment initiated"

# Install Tempo
echo "🔍 Installing Tempo..."
helm upgrade --install tempo grafana/tempo \
  --namespace monitoring \
  --values values-tempo.yaml \
  --timeout 10m
echo "✅ Tempo deployment initiated"

# Wait for deployments to be ready (more reliable than Helm --wait)
echo "⏳ Waiting for pods to be ready..."
echo "   This may take a few minutes for all components to start..."

# Wait for key deployments to be available
kubectl wait --for=condition=available --timeout=300s deployment/kube-prometheus-stack-operator -n monitoring 2>/dev/null || echo "   Prometheus Operator: Still starting..."
kubectl wait --for=condition=available --timeout=300s deployment/kube-prometheus-stack-grafana -n monitoring 2>/dev/null || echo "   Grafana: Still starting..."
kubectl wait --for=condition=available --timeout=300s deployment/loki -n monitoring 2>/dev/null || echo "   Loki: Still starting..."
kubectl wait --for=condition=available --timeout=300s deployment/tempo -n monitoring 2>/dev/null || echo "   Tempo: Still starting..."

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "📊 Current Status:"
kubectl get pods -n monitoring --no-headers 2>/dev/null | awk '{print "  • " $1 ": " $3}' || echo "  • Checking pod status..."
echo ""
echo "📊 Access Information:"
echo "  • Grafana: Available via Tailscale at 'grafana-aks'"
echo "  • Default credentials: admin/admin (change on first login)"
echo ""
echo "🔧 Useful Commands:"
echo "  kubectl get pods -n monitoring                    # Check pod status"
echo "  kubectl get pvc -n monitoring                     # Check storage"
echo "  helm list -n monitoring                           # Check Helm releases"
echo "  kubectl logs -n monitoring deployment/loki        # Check Loki logs"
echo ""
echo "💡 Note: If some pods are still 'ContainerCreating' or 'Pending',"
echo "   they may still be starting up. This is normal for the first deployment."
echo ""
echo "🚀 Your observability stack is ready!"
