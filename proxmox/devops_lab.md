---

# ENTERPRISE-GRADE KUBERNETES DEVOPS LAB ON ORACLE CLOUD FREE TIER

## Complete Architecture & Implementation Guide

---

## EXECUTIVE SUMMARY

As a **senior DevOps engineer** designing this for myself, I would build a **hybrid architecture** that maximizes resource efficiency while supporting:

- ✅ **3-node Kubernetes cluster** (1 Master + 2 Workers) with pod scaling
- ✅ **Complete CI/CD pipeline** (Jenkins + GitLab/GitHub integration)
- ✅ **Image registry** (Nexus) with Docker image management
- ✅ **Production-grade monitoring** (Prometheus + Grafana)
- ✅ **Logging infrastructure** (ELK-lite or Loki)
- ✅ **Network segmentation** with proper VPC/networking

**Key insight:** Instead of traditional dedicated servers, use **containerized services** and **lightweight kubernetes distributions** (K3s/MicroK8s) to maximize efficiency.

---

# PART 1: INFRASTRUCTURE DESIGN

## Resource Allocation Strategy

### **Total Available Resources:**

```
Ampere A1 Flex:     4 OCPU, 24GB RAM, 200GB Storage
E2 Micro (Fixed):   2 instances @ 1/8 OCPU, 1GB RAM each (separate pool)
────────────────────────────────────────────────────────────────
TOTAL USEFUL:       ~4.25 OCPU, 26GB RAM, 200GB Storage
```

### **Optimal Distribution for Kubernetes Lab:**

| Component                      | Instance      | Shape    | OCPU     | RAM      | Storage   | Purpose                                 |
| ------------------------------ | ------------- | -------- | -------- | -------- | --------- | --------------------------------------- |
| **K8s Master + Control Plane** | kube-master   | A1.Flex  | 1.5      | 8GB      | 50GB      | API Server, Scheduler, etcd, networking |
| **K8s Worker 1**               | kube-worker-1 | A1.Flex  | 1        | 6GB      | 50GB      | Run application pods (test replicas)    |
| **K8s Worker 2**               | kube-worker-2 | E2.Micro | 1/8      | 1GB      | 50GB      | Lightweight pods/sidecars (testing)     |
| **CI/CD Pipeline**             | jenkins-nexus | A1.Flex  | 1        | 8GB      | 50GB      | Jenkins + Nexus (combined)              |
| **Monitoring Stack**           | monitoring    | E2.Micro | 1/8      | 1GB      | 50GB      | Prometheus + Grafana (lightweight)      |
| **Utility/Bastion**            | bastion       | Optional | -        | -        | -         | SSH jump host (can use one K8s node)    |
| **TOTAL ALLOCATION**           |               |          | **3.75** | **24GB** | **200GB** | ✅ Within limits                        |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│         ORACLE CLOUD VCN (Virtual Cloud Network)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           KUBERNETES CLUSTER (K3s/MicroK8s)              │  │
│  │                                                             │  │
│  │  ┌──────────────────┐    ┌──────────────┐  ┌──────────┐ │  │
│  │  │  MASTER NODE     │    │  WORKER 1    │  │ WORKER 2 │ │  │
│  │  │  kube-master     │    │ kube-worker-1│  │(Micro)   │ │  │
│  │  │                  │    │              │  │          │ │  │
│  │  │ 1.5 OCPU, 8GB    │    │ 1 OCPU, 6GB  │  │1/8,1GB   │ │  │
│  │  │ 50GB storage     │    │ 50GB storage │  │50GB      │ │  │
│  │  │                  │    │              │  │          │ │  │
│  │  │ • API Server     │    │ • Kubelet    │  │• Docker  │ │  │
│  │  │ • Scheduler      │    │ • Pods (3-4) │  │• Pods    │ │  │
│  │  │ • etcd           │    │ • Test Apps  │  │(sidecars)│ │  │
│  │  │ • Controllers    │    │              │  │          │ │  │
│  │  └──────────────────┘    └──────────────┘  └──────────┘ │  │
│  │                                                             │  │
│  │  All running K3s (ultra-lightweight Kubernetes)            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                   │
│         ┌────────────────────┴──────────────────────┐           │
│         │                                            │           │
│  ┌──────▼──────────────────────┐  ┌────────────────▼───────┐  │
│  │   CI/CD & ARTIFACT STORAGE   │  │ MONITORING & LOGGING   │  │
│  │   jenkins-nexus              │  │ monitoring              │  │
│  │   (A1.Flex)                  │  │ (E2.Micro)              │  │
│  │   1 OCPU, 8GB, 50GB          │  │ 1/8 OCPU, 1GB, 50GB    │  │
│  │                              │  │                         │  │
│  │ • Jenkins (CI/CD)            │  │ • Prometheus            │  │
│  │ • Nexus (Image Registry)     │  │ • Grafana (Dashboard)   │  │
│  │ • Build Pipelines            │  │ • Node Exporters        │  │
│  │ • Docker Image Builds        │  │ • K8s Monitoring       │  │
│  │                              │  │ • Alertmanager          │  │
│  └──────────────────────────────┘  └─────────────────────────┘  │
│                                                                   │
│  All instances in same VCN with private networking              │
│  Security Groups configured for inter-service communication     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 2: DETAILED INSTANCE CONFIGURATION

## Instance 1: Kubernetes Master Node (kube-master)

**Purpose:** Control plane, API server, scheduler, etcd database

```yaml
Instance Details:
├─ Name: kube-master
├─ Shape: VM.Standard.A1.Flex
├─ OCPU: 1.5 (sufficient for master control)
├─ Memory: 8GB (6GB for K3s + services, 2GB buffer)
├─ Boot Volume: 50GB
├─ OS: Ubuntu 24.04 LTS (ARM)
├─ Network: Private IP in VCN + 1 Public IP (for SSH only)
└─ Security Group: Allow inbound 22 (SSH), 6443 (K8s API)

Services Running:
├─ K3s Master/Control Plane
├─ etcd (Kubernetes database)
├─ API Server (port 6443)
├─ Scheduler
├─ Controller Manager
├─ kube-proxy
└─ Flannel CNI (networking)

Resource Usage Estimate:
├─ Linux OS: ~1GB
├─ K3s/etcd: ~2GB
├─ Kube-apiserver: ~1.5GB
├─ Monitoring agents: ~0.5GB
└─ Available for pods: ~3GB (if needed for utilities)

CPU Usage: ~0.3 OCPU average (mostly idle, spikes during pod scheduling)
```

---

## Instance 2: Kubernetes Worker 1 (kube-worker-1)

**Purpose:** Primary application node for testing deployments, replicas

```yaml
Instance Details:
├─ Name: kube-worker-1
├─ Shape: VM.Standard.A1.Flex
├─ OCPU: 1 (good for running 3-4 test pods)
├─ Memory: 6GB (5GB for pods, 1GB OS)
├─ Boot Volume: 50GB
├─ OS: Ubuntu 24.04 LTS (ARM)
├─ Network: Private IP in VCN, no public IP (use bastion SSH)
└─ Security Group: Allow inbound 10250 (Kubelet), 30000-32767 (NodePort)

Services Running:
├─ K3s Agent (kubelet)
├─ Container Runtime (containerd/Docker)
├─ kube-proxy
├─ Network plugins
└─ Pod workloads (3-4 pods with 2-4 replicas each)

Pod Capacity Example:
├─ Nginx test deployment: 3 replicas × 100MB = 300MB
├─ MySQL test database: 1 × 800MB = 800MB
├─ Custom app container: 4 replicas × 400MB = 1600MB
├─ Monitoring agents: ~500MB
└─ Total: ~3.2GB (leaves buffer for testing)

CPU Allocation:
├─ Pod 1: 0.1 OCPU
├─ Pod 2: 0.15 OCPU
├─ Pod 3: 0.25 OCPU
├─ Pod 4: 0.1 OCPU
└─ Available: 0.4 OCPU (for burstable workloads)
```

---

## Instance 3: Kubernetes Worker 2 (kube-worker-2)

**Purpose:** Ultra-lightweight worker for testing, sidecars, monitoring agents

```yaml
Instance Details:
├─ Name: kube-worker-2
├─ Shape: VM.Standard.E2.1.Micro (FIXED: 1/8 OCPU, 1GB RAM)
├─ Boot Volume: 50GB (only 50GB used, rest available)
├─ OS: Ubuntu 24.04 LTS (x86)
├─ Network: Private IP in VCN, no public IP
└─ Security Group: Allow 10250 (Kubelet), 30000-32767

Services Running:
├─ K3s Agent (kubelet) - very lightweight
├─ Container Runtime
├─ Monitoring node exporter
└─ Test lightweight pods (DaemonSets, sidecar containers)

Pod Capacity:
├─ Lightweight containers only: 200-300MB total
├─ Great for testing init containers
├─ Perfect for DaemonSets (logging, monitoring)
├─ Cannot run memory-heavy apps here
└─ Acts as "edge" worker for multi-cloud testing

Burstable CPU Note:
├─ Baseline: 1/8 OCPU = 125m
├─ Can burst to: 1 OCPU temporarily
└─ Good for: Intermittent tasks, sidecars, agents
```

---

## Instance 4: CI/CD & Artifact Storage (jenkins-nexus)

**Purpose:** Continuous Integration/Continuous Deployment + Docker image registry

```yaml
Instance Details:
├─ Name: jenkins-nexus
├─ Shape: VM.Standard.A1.Flex
├─ OCPU: 1 (builds are CPU-intensive but batched)
├─ Memory: 8GB (split between services)
├─ Boot Volume: 50GB
├─ OS: Ubuntu 24.04 LTS (ARM)
├─ Network: Private IP + 1 Public IP (for external GitHub webhooks)
└─ Security Groups: Allow 22 (SSH), 8080 (Jenkins), 8081 (Nexus), 443 (HTTPS)

Service 1: Jenkins (6GB allocated)
├─ Port: 8080 (HTTP)
├─ Plugins: Kubernetes, Docker, GitLab/GitHub, Pipeline
├─ Executors: 2 concurrent builds (memory efficient)
├─ Memory: 4GB (Java heap max 2GB)
├─ Purpose: Pull → Build → Test → Deploy to K8s
└─ Build time: ~3-5 min per build (on 1 OCPU)

Service 2: Nexus Repository Manager (2GB allocated)
├─ Port: 8081 (HTTP/REST)
├─ Storage: 40GB for Docker images
├─ Purpose: Store Docker images, dependencies
├─ Memory: 1.5GB (Java heap max 800MB)
├─ Image retention: Keep last 5 builds
└─ Anonymous access disabled for security

Sample CI/CD Pipeline:
1. Developer pushes code to GitHub
2. GitHub webhook triggers Jenkins
3. Jenkins polls repo, creates workspace
4. Build stage: Compile, unit tests
5. Docker stage: Build image, tag
6. Push to Nexus registry
7. Deploy stage: Push manifest to K8s
8. K8s pulls image from Nexus
9. Deployment runs test replicas
10. Prometheus scrapes metrics

Resource Timing:
├─ Jenkins startup: ~30 seconds
├─ Build execution: 3-5 minutes per pipeline
├─ Nexus startup: ~45 seconds
├─ Typical queue: 2 builds waiting (not concurrent)
└─ CPU burst during builds: 0.8-1.0 OCPU
```

---

## Instance 5: Monitoring & Observability (monitoring)

**Purpose:** Prometheus metrics collection + Grafana dashboards + Alerting

```yaml
Instance Details:
├─ Name: monitoring
├─ Shape: VM.Standard.E2.1.Micro (FIXED: 1/8 OCPU, 1GB RAM)
├─ Boot Volume: 50GB
├─ OS: Ubuntu 24.04 LTS (x86)
├─ Network: Private IP only (no public IP needed)
└─ Security Groups: Allow 9090 (Prometheus), 3000 (Grafana)

Service 1: Prometheus (600MB allocated)
├─ Port: 9090
├─ Scrape interval: 30 seconds (low overhead)
├─ Retention: 7 days (fits in allocated storage)
├─ Memory: ~400MB
├─ Scrape targets:
│  ├─ kube-master (kubelet, API, etcd metrics)
│  ├─ kube-worker-1 (node metrics, pod metrics)
│  ├─ kube-worker-2 (node metrics, pod metrics)
│  ├─ jenkins (custom metrics plugin)
│  ├─ nexus (metrics endpoint)
│  └─ monitoring (prometheus self-metrics)
└─ Total scrape load: ~5 targets × 50 metrics = 250 metrics/scrape

Service 2: Grafana (300MB allocated)
├─ Port: 3000
├─ Memory: ~250MB
├─ Dashboards:
│  ├─ K8s Cluster Overview (CPU, RAM, Network)
│  ├─ Pod Autoscaling Metrics
│  ├─ Jenkins Build History
│  ├─ Node Health
│  ├─ Application Performance
│  └─ Custom test dashboards
├─ Alerts: Memory > 80%, CPU > 90%, Pod errors
└─ Data Source: Prometheus

Service 3: Supporting Components
├─ node-exporter (all nodes): Collect system metrics
├─ kube-state-metrics (on master): K8s object metrics
```
