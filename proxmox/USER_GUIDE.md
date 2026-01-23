
# 🚀 K3s Lab DevOps – Kubernetes Admin User Guide (Beginner Friendly)

This document is a **practical user guide for Kubernetes administrators** working with a **K3s cluster**.
It explains **what to do**, **when to do it**, **why it matters**, and **what can go wrong**.

This guide is written for **junior admins**, but follows **real-world best practices**.

---

## 🧠 Before You Begin (Important Concepts)

### What is K3s?

* A **lightweight Kubernetes distribution**
* Ideal for labs, edge, CI/CD, and learning
* Uses **containerd** (not Docker) by default

### Cluster Layout (This Lab)

| Role            | IP              |
| --------------- | --------------- |
| Master          | `192.168.0.210` |
| Worker 1        | `192.168.0.211` |
| Worker 2        | `192.168.0.212` |
| Jenkins + Nexus | `192.168.0.213` |

---

## 🔐 Kubectl Access & Permissions

> ⚠️ **Common Beginner Issue**

If you see:

error loading config file "/etc/rancher/k3s/k3s.yaml": permission denied

### ✅ Correct Setup (Recommended)

Allow `ansible` user to read kubeconfig:

sudo chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

> ✔️ After this, you should NOT need `sudo kubectl`

---

## 🏗️ 1. Namespace Management

### What is a Namespace?

* Logical isolation inside one cluster
* Think of it as **folders for workloads**
* Deleting a namespace **deletes everything inside it**

### 🔍 List Namespaces


kubectl get ns


### ➕ Create a Namespace


kubectl create namespace my-app

### ❌ Delete a Namespace (⚠️ Destructive)

kubectl delete namespace my-app

> ⚠️ **Risk**
>
> * This deletes **pods, services, secrets, configmaps**
> * There is **NO undo**

### 📌 Best Practice

* Use namespaces like:

  * `dev`
  * `staging`
  * `prod`
  * `monitoring`
  * `jenkins`

---

## 📦 2. Pod Management (Lowest-Level Object)

### What is a Pod?

* Smallest runnable unit
* One or more containers
* **Pods are NOT self-healing**

> ⚠️ Never run production workloads as standalone pods.

---

### 🏃 Run a Test Pod (Debugging Only)

kubectl run test-pod --image=nginx:alpine

---

### 🔍 Inspect Pods

| Action         | Command                        |
| -------------- | ------------------------------ |
| List pods      | `kubectl get pods`             |
| All namespaces | `kubectl get pods -A`          |
| Watch changes  | `kubectl get pods -w`          |
| Detailed info  | `kubectl describe pod <pod>`   |
| Logs           | `kubectl logs <pod>`           |
| Shell access   | `kubectl exec -it <pod> -- sh` |

---

### ❌ Delete a Pod

kubectl delete pod <pod-name>

> ⚠️ If pod is managed by a Deployment → it will be recreated automatically.

---

## 📈 3. Deployments (What You SHOULD Use)

### Why Deployments?

* Self-healing
* Supports scaling
* Supports rolling updates
* Restart pods automatically


### 🚀 Create a Deployment


kubectl create deployment web-server \
  --image=nginx:alpine \
  --replicas=3

### 🔍 Check Deployment

kubectl get deployments
kubectl get pods

---

### ⚖️ Scale Replicas

kubectl scale deployment web-server --replicas=5

### 📌 Best Practice

* Never use `kubectl run` for real apps
* Always use **Deployment / StatefulSet**

---

## 🌐 4. Services & Networking

### Why Services?

* Pods have **dynamic IPs**
* Services provide **stable access**

---

### 🔌 Service Types (Beginner View)

| Type         | Use Case                      |
| ------------ | ----------------------------- |
| ClusterIP    | Internal only (default)       |
| NodePort     | External access (lab/testing) |
| LoadBalancer | Cloud / MetalLB               |
| Ingress      | Production HTTP routing       |

---

### 🌍 Expose via NodePort (Lab Use)

kubectl expose deployment web-server \
  --type=NodePort \
  --port=80 \
  --name=web-service

---

### 🔎 Find NodePort

kubectl get svc web-service

Example:

    ```
80:30614/TCP


Access via:


http://192.168.0.210:30614
http://192.168.0.211:30614
http://192.168.0.212:30614
```

> ⚠️ **404 does NOT mean networking is broken**
> It means your app returned 404.

---

## 🐳 5. Private Registry (Nexus)

### Registry Address


192.168.0.213:5000

---

### 🔐 Push Images (CI / Jenkins / Admin Node)

docker login 192.168.0.213:5000
docker tag my-app:v1 192.168.0.213:5000/my-app:v1
docker push 192.168.0.213:5000/my-app:v1

---

### 🔓 Pull Images in Kubernetes


image: 192.168.0.213:5000/my-app:v1


✔️ Anonymous pulls are enabled
✔️ containerd is configured correctly

---

## 🧪 6. Connectivity Validation Checklist

### ✅ Cluster Health

kubectl get nodes

All nodes must be `Ready`.

---

### ✅ Registry Connectivity Test

kubectl run registry-test \
  --image=192.168.0.213:5000/test-alpine \
  -- sleep 3600

If pod runs → registry works.

---

### ✅ Network Ports (Node Level)

ss -lntup

Look for:

* `6443` → Kubernetes API
* NodePort range `30000-32767`

---

## 🛠️ 7. Troubleshooting Guide (Very Important)

---

### ❌ Pod stuck in `ImagePullBackOff`

**Check:**

1. Image name & tag
2. Nexus is reachable
3. Image exists


kubectl describe pod <pod>

---

### ❌ Cannot run kubectl without sudo

ls -l /etc/rancher/k3s/k3s.yaml


Fix:

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

---

### ❌ NodePort not accessible

Checklist:

* Pod is `Running`
* Service type is `NodePort`
* Correct port used
* App actually listens on port 80

---

### ❌ 404 on NodePort

This is **application-level**, not Kubernetes.

Test inside pod:

kubectl exec -it <pod> -- curl localhost

---

## 🧹 8. Safe Cleanup

Delete test namespaces when done:

kubectl delete ns demo
kubectl delete ns registry-test


⚠️ Never delete:

* `kube-system`
* `kube-public`
* `kube-node-lease`

---

## 📌 Admin Best Practices (Remember This)

✅ Use namespaces
✅ Use Deployments, not Pods
✅ Avoid NodePort in production
✅ Use Ingress for HTTP apps
✅ Store manifests in Git
✅ Never edit live resources manually in prod

---

## 🎯 What You’re Ready For Next

Now we have:

* A healthy multi-node cluster
* Working private registry
* CI/CD-ready environment

Next steps:

* Jenkins → K3s deployment pipeline
* Ingress + TLS
* Monitoring (Prometheus/Grafana)
* Helm-based deployments
