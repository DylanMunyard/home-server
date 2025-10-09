#!/bin/bash
# Clean uninstall script for the observability stack

set -e

echo "🧹 Uninstalling Observability Stack from AKS"
echo "============================================="

# Uninstall Helm releases
echo "📦 Uninstalling Helm releases..."

if helm list -n monitoring | grep -q tempo; then
    echo "  Removing Tempo..."
    helm uninstall tempo -n monitoring
fi

if helm list -n monitoring | grep -q loki; then
    echo "  Removing Loki..."
    helm uninstall loki -n monitoring
fi

if helm list -n monitoring | grep -q kube-prometheus-stack; then
    echo "  Removing Prometheus Stack..."
    helm uninstall kube-prometheus-stack -n monitoring
fi

echo "✅ Helm releases removed"

# Wait a bit for pods to terminate
echo "⏳ Waiting for pods to terminate..."
sleep 10

# Delete PVCs (this will delete the data!)
echo "💾 Removing persistent volume claims..."
kubectl delete pvc --all -n monitoring --ignore-not-found=true
echo "✅ PVCs removed"

# Optional: Delete the namespace (uncomment if you want to start completely fresh)
echo "🗑️  Removing monitoring namespace..."
kubectl delete namespace monitoring --ignore-not-found=true
echo "✅ Namespace removed"

echo ""
echo "🎉 Clean uninstall complete!"
echo "=========================="
echo ""
echo "⚠️  WARNING: All monitoring data has been deleted!"
echo ""
echo "🚀 Ready for fresh installation with:"
echo "  ./install.sh"
