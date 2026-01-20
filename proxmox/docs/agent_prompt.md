Excellent — what you have now is **already a solid platform baseline**.
Your dynamic Proxmox inventory + validation playbook is _exactly_ the right direction, and it solves the “wrong host touched” problem cleanly.

Below is a **ready-to-use prompt** you can give to your **other coding agent**, followed by **why this prompt is better than your current setup** and **what improvements it enforces**.

You can copy-paste this verbatim.

---

## ✅ Suggested Prompt for the Automation / Refactor Agent

---

### 🎯 Role & Goal

You are a **Platform Automation Engineer** responsible for **hardening and refactoring** an existing Proxmox + Terraform + Ansible + Jenkins + K3s lab into a **repeatable, least-privilege, fully automated CI/CD platform**.

Your task is **NOT** to redesign from scratch, but to **correct weaknesses**, **remove unsafe assumptions**, and **implement missing automation tasks** based on the current working system.

---

### 🧠 Context You Must Assume

The current environment already has:

- Proxmox hypervisor
- Terraform provisioning QEMU VMs
- Dynamic Ansible inventory using `community.general.proxmox`
- K3s Kubernetes cluster (containerd runtime)
- Jenkins + Nexus on a CI VM
- Jenkins pipeline that successfully:

  - builds Docker images
  - pushes to Nexus
  - deploys to Kubernetes

However, several steps were previously done **manually** and must now be automated and hardened.

---

### 📌 Key Constraints (Do Not Break These)

1. **Dynamic Inventory Only**

   - Hosts must be selected **only by Proxmox tags**
   - Never rely on static IPs or static inventories
   - Do NOT touch unrelated Proxmox VMs (e.g., jellyfin, nextcloud)

2. **Separation of Responsibilities**

   - Terraform → infrastructure only
   - Ansible → OS, k3s, registry, access, validation
   - Jenkins → build, push, deploy (no host bootstrapping)

3. **K3s Runtime Reality**

   - K3s uses `containerd`
   - Docker must NOT be installed on Kubernetes nodes
   - Registry access must be configured via `registries.yaml`

---

### 🔧 Tasks You Must Implement

#### 1️⃣ Fix Jenkins → Kubernetes Authentication (CRITICAL)

Current problem:

- Jenkins uses **cluster-admin kubeconfig**
- Causes security risk and stage-to-stage auth failures

You must:

- Create a **dedicated Kubernetes ServiceAccount**:

  - Name: `jenkins-deployer`
  - Namespace: `default` (or configurable)

- Create a **Role or ClusterRole** with minimal permissions:

  - deployments (get, list, update, patch)
  - pods (get, list)
  - services (get, list)

- Bind the Role to the ServiceAccount
- Generate a **scoped kubeconfig** from the ServiceAccount token
- Store this kubeconfig as a **Jenkins credential**
- Update Jenkins pipeline to use ONLY this kubeconfig

❌ Jenkins must NOT use `/etc/rancher/k3s/k3s.yaml`

---

#### 2️⃣ Refine Jenkins Pipeline (Stateless & Deterministic)

You must refactor the Jenkinsfile so that:

- `KUBECONFIG` is set **once globally**, not per stage
- Authentication does not reset between stages
- Verification stage failures do NOT invalidate successful deployments unless truly broken
- Replace deprecated `kubectl set image --record`
- Add **pre-flight checks**:

  - `kubectl auth can-i update deployment`
  - `kubectl get nodes`
  - fail fast if access is broken

Optional but preferred:

- Replace imperative `kubectl set image` with:

  - `kubectl apply`
  - or Helm (if appropriate)

---

#### 3️⃣ Automate Kubernetes Bootstrap via Ansible

Ansible must:

- Install `kubectl` on CI host only
- Copy **scoped kubeconfig** to Jenkins user (or inject via credentials)
- Validate cluster access using:

  ```bash
  kubectl get nodes
  ```

- Apply base Kubernetes manifests (namespace, deployment, service)
  **before Jenkins ever runs**

---

#### 4️⃣ Harden Registry Configuration (containerd)

Ensure that **every Kubernetes node** has:

- `/etc/rancher/k3s/registries.yaml`
- HTTP Nexus registry configured
- K3s / k3s-agent restarted via Ansible handlers

Include:

- idempotency
- validation that image pull works from nodes

---

#### 5️⃣ Improve Validation Playbooks

Extend `validate.yml` to include:

- Jenkins → Kubernetes auth check
- Registry reachability **from Kubernetes nodes**
- Node readiness check:

  ```bash
  kubectl get nodes
  ```

- Fail with **clear messages**, not generic errors

---

#### 6️⃣ Inventory & Safety Improvements

Review the existing Proxmox dynamic inventory and:

- Ensure grouping by **tags and hostname patterns**
- Prevent accidental inclusion of non-lab VMs
- Avoid hardcoded credentials (move to vault/env vars)
- Make `ansible_user` configurable, not hardcoded

---

### 📂 Expected Output

You should produce:

1. Updated Ansible roles and tasks
2. Kubernetes RBAC manifests for Jenkins
3. Refactored Jenkinsfile
4. Clear explanation of:

   - what was changed
   - why it fixes the original issues
   - how it improves automation maturity

---

### 🧠 Design Principles to Follow

- Least privilege
- Idempotency
- Deterministic builds
- Zero manual server access after first bootstrap
- Fail fast, fail clearly

---

## 🏆 Why This Prompt Is Better Than the Current Setup

### 1️⃣ It eliminates **cluster-admin abuse**

Your current setup _works_, but Jenkins has **god access**.
This prompt forces **proper RBAC**, which is a real-world requirement.

---

### 2️⃣ It removes hidden state

Before:

- kubeconfig copied manually
- environment resets between Jenkins stages

After:

- credentials are explicit
- pipeline is stateless
- failures are predictable

---

### 3️⃣ It enforces runtime truth

You already learned:

> Docker build success ≠ Kubernetes runtime success

This prompt ensures:

- containerd is configured properly
- registry issues are caught **before deploy**

---

### 4️⃣ It protects non-lab VMs

Dynamic inventory + tag filtering ensures:

- Jellyfin / Nextcloud / home infra stays untouched
- No “oops Ansible ran on the wrong host”

---

### 5️⃣ It upgrades you from “automation that works”

to **platform automation**

This is the difference between:

- a lab that runs
- and a platform you can rebuild confidently anytime

---

## 🔜 Recommended Next Step After This

Once this refactor is done, the **next logical evolution** is:

- Jenkins agents running inside Kubernetes
- Helm-based deployments
- GitOps (ArgoCD / Flux)

But **do not skip this RBAC + pipeline hardening step** — it’s the foundation.

---

If you want, next I can:

- Review the agent’s output
- Design the exact RBAC YAML
- Produce a “final architecture diagram”
- Or help you convert this into a **portfolio-grade case study**

Just tell me.
