#!/bin/bash
# save as: health-check.sh

echo "=== Infrastructure Health Check ==="

# Test instance connectivity
echo "Testing SSH connectivity..."
for ip in 10.0.1.10 10.0.1.20 10.0.1.30 10.0.1.40 10.0.1.50; do
    timeout 3 bash -c "echo > /dev/tcp/$ip/22" && echo "✓ $ip SSH OK" || echo "✗ $ip SSH FAILED"
done

# Test Kubernetes
echo -e "\n=== Kubernetes Status ==="
kubectl get nodes
kubectl get pods -A

# Test services
echo -e "\n=== Service Status ==="
curl -s http://10.0.1.50:9090/-/healthy && echo "✓ Prometheus OK" || echo "✗ Prometheus FAILED"
curl -s http://10.0.1.50:3000/api/health && echo "✓ Grafana OK" || echo "✗ Grafana FAILED"
curl -s -I http://10.0.1.40:8080 | head -1 && echo "✓ Jenkins OK" || echo "✗ Jenkins FAILED"
curl -s -I http://10.0.1.40:8081 | head -1 && echo "✓ Nexus OK" || echo "✗ Nexus FAILED"

# Check resources
echo -e "\n=== Resource Usage ==="
free -h
df -h /
kubectl top nodes 2>/dev/null || echo "Metrics not available yet"

echo -e "\n=== Health Check Complete ==="