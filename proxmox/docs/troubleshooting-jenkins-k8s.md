This is written to **capture the lessons learned** and turn them into **proper automation maturity** 👍:

- Clearly **describe the problems**
- Explain **why they happened**
- Show **how we fixed them**
- Describe **how a better Ansible playbook would have prevented them**

No fluff, no guesswork — this is production-grade documentation.

---

# Jenkins → Nexus → K3s Deployment

## Troubleshooting & Automation Lessons Learned

## Overview

This document describes the issues encountered while deploying a containerized application to a **K3s Kubernetes cluster** using a **Jenkins CI/CD pipeline**, and how they were resolved.

It also outlines how these issues **should have been avoided** through better **Ansible automation** after infrastructure provisioning with Terraform.

---

## Architecture Summary

- **Terraform**: Provisioned VMs

  - `kube-master`
  - `kube-worker-1`
  - `kube-worker-2`
  - `jenkins-nexus`

- **K3s**: Kubernetes distribution (containerd runtime)
- **Jenkins**: CI/CD runner on `jenkins-nexus`
- **Nexus**: Docker registry (`192.168.0.33:5000`)
- **Registry Type**: HTTP (insecure)
- **Deployment Model**:

  - Jenkins builds image
  - Pushes to Nexus
  - Updates Kubernetes Deployment via `kubectl`

---

## Problems Encountered

### 1. Jenkins Could Not Authenticate to Kubernetes

#### Symptoms

During Jenkins pipeline execution:

```text
Authentication required
Error from server (Forbidden)
couldn't get current server API group list
```

#### Root Cause

- Jenkins agent did not have a valid **kubeconfig**
- `kubectl` defaulted to a web-auth redirect (`/login`)
- `KUBECONFIG` was not explicitly set
- Jenkins user did not have permission to read K3s kubeconfig

#### Fix Applied

1. Copied kubeconfig to Jenkins user home:

   ```bash
   mkdir -p /home/terraform/.kube
   cp /etc/rancher/k3s/k3s.yaml /home/terraform/.kube/config
   chown -R terraform:terraform /home/terraform/.kube
   chmod 600 /home/terraform/.kube/config
   ```

2. Explicitly set kubeconfig in Jenkinsfile:

   ```groovy
   environment {
       KUBECONFIG = '/home/terraform/.kube/config'
   }
   ```

---

### 2. `deployment not found` Error

#### Symptoms

```text
Error from server (NotFound): deployments.apps "static-site" not found
```

#### Root Cause

- Jenkins pipeline attempted:

  ```bash
  kubectl set image deployment/static-site ...
  ```

- But **Deployment had never been created** in the cluster

#### Fix Applied

Added deployment step before image update:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

### 3. Pods Stuck in `ImagePullBackOff`

#### Symptoms

```text
ImagePullBackOff
http: server gave HTTP response to HTTPS client
```

#### Root Cause

- K3s uses **containerd**, not Docker
- Nexus registry was **HTTP**
- containerd **defaults to HTTPS**
- No registry mirror configuration existed on nodes

#### Why This Was Confusing

- Jenkins could:

  - Build image
  - Push image

- But Kubernetes nodes **could not pull** the same image

This is expected: **build-time Docker ≠ runtime containerd**

#### Fix Applied

Created `/etc/rancher/k3s/registries.yaml` on **all nodes**:

```yaml
mirrors:
  '192.168.0.33:5000':
    endpoint:
      - 'http://192.168.0.33:5000'
```

Restarted K3s:

```bash
# master
systemctl restart k3s

# workers
systemctl restart k3s-agent
```

---

### 4. Rollout Hanging / Timeout

#### Symptoms

```text
kubectl rollout status ... timed out waiting for the condition
```

#### Root Cause

- Some pods were running
- Others failed image pull
- Deployment was partially updated
- Rollout could not complete

#### Fix Applied

- Fixed registry configuration
- Redeployed
- Rollout completed successfully

---

### 5. Jenkins Verify Stage Still Failed (False Negative)

#### Symptoms

```text
Authentication required
Forbidden
```

Even though:

```bash
kubectl get pods
# All pods Running
```

#### Root Cause

- Jenkins Verify stage was **not consistently using KUBECONFIG**
- Jenkins environment reset between stages

#### Fix Applied

- Ensured `KUBECONFIG` is defined at stage level or pipeline level
- Deployment itself was already successful

---

## How We Verified the App Was Actually Running

### Service & Endpoints

```bash
kubectl get svc static-site
kubectl get endpoints static-site
```

Result:

- NodePort assigned
- Endpoints mapped to running pods

### In-Cluster Test

```bash
kubectl run curl-test --rm -it \
  --image=curlimages/curl \
  --restart=Never \
  -- http://static-site
```

### Browser Access

```text
http://<node-ip>:<nodeport>
```

---

## Why This Was Not “Fully Automated”

Terraform provisioned infrastructure correctly, but **post-provisioning configuration was incomplete**.

Key runtime assumptions were **not automated**.

---

## What a Proper Ansible Playbook Should Have Done

### 1. Kubernetes Access Setup

- Copy kubeconfig to Jenkins user
- Set correct permissions
- Optionally create a **service account + RBAC**
- Store kubeconfig as Jenkins credential

### 2. Registry Configuration (CRITICAL)

On **every Kubernetes node**:

- Create `/etc/rancher/k3s/registries.yaml`
- Configure HTTP Nexus registry
- Restart k3s / k3s-agent

This alone would have prevented **ImagePullBackOff** entirely.

---

### 3. Jenkins Node Preparation

- Install:

  - Docker
  - kubectl

- Configure:

  - KUBECONFIG
  - PATH

- Validate access:

  ```bash
  kubectl get nodes
  ```

---

### 4. Kubernetes Bootstrap

Ansible should have:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

**Before** Jenkins ever runs.

---

### 5. Health Validation (Pre-flight Checks)

Ansible should validate:

- Registry reachable from all nodes
- Image pull test using containerd
- Jenkins → API server connectivity

---

## Key Lessons Learned

| Area         | Lesson                                      |
| ------------ | ------------------------------------------- |
| CI/CD        | Jenkins success ≠ cluster success           |
| K3s          | Uses containerd, not Docker                 |
| Registry     | HTTP registry must be explicitly configured |
| Automation   | Terraform ≠ complete system                 |
| Verification | Always test from cluster perspective        |

---

## Final Status

✅ Infrastructure provisioned
✅ Registry configured
✅ Jenkins pipeline functional
✅ Kubernetes deployment successful
✅ Application accessible via browser

---

## Next Automation Milestone

- Move all manual fixes into Ansible
- Add **pre-flight validation role**
- Add **Jenkins credential-based kubeconfig**
- Enforce **immutable deployments**

---

What we can do next?

- Design the **exact Ansible roles** you need
- Refactor your Jenkinsfile to be **stateless**
- Introduce **Helm** for cleaner deployments
- Add **pipeline health checks** that fail fast and clearly
