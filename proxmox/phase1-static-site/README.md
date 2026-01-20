# Phase 1: Static Website Application

## Directory Structure
```
phase1-static-site/
├── Dockerfile              # Docker image definition
├── index.html             # Main HTML page
├── style.css              # Styling
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Deployment configuration
│   └── service.yaml       # Service configuration
└── Jenkinsfile            # CI/CD pipeline
```

## Quick Start

### 1. Manual Deployment (Test K8s)
```bash
# Create deployment and service
kubectl apply -f k8s/

# Check status
kubectl get deployments
kubectl get pods
kubectl get services

# Get NodePort
kubectl get svc static-site

# Access application
# http://<any-worker-ip>:<nodeport>
```

### 2. Jenkins Pipeline Deployment
1. Create new Pipeline job in Jenkins
2. Point to this repository
3. Run pipeline
4. Access from Nexus-hosted image

### 3. Testing Commands
```bash
# Scale replicas
kubectl scale deployment static-site --replicas=5

# Delete a pod (test self-healing)
kubectl delete pod <pod-name>

# Rolling update (after changing HTML)
kubectl rollout restart deployment static-site

# Check rollout status
kubectl rollout status deployment static-site
```

## Files Included

- **Dockerfile**: Multi-stage build for optimized image
- **index.html**: Sample landing page with DevOps theme
- **style.css**: Modern, responsive styling
- **k8s/deployment.yaml**: Deployment with 3 replicas, resource limits
- **k8s/service.yaml**: NodePort service for external access
- **Jenkinsfile**: Complete CI/CD pipeline with Nexus integration
