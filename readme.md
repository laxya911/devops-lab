# k8s-devops-lab

A hands-on **DevOps & Kubernetes lab** designed to build, test, and automate **real-world infrastructure and application delivery pipelines** across multiple platforms (on-prem and cloud).

This repository serves as both:
- A **learning & experimentation environment**
- A **portfolio project** to demonstrate practical DevOps skills used in production systems

---

## 🎯 Project Goals

The primary goals of this project are to:

- Design and implement **realistic end-to-end DevOps workflows**
- Automate infrastructure provisioning, configuration, and application delivery
- Practice **production-style Kubernetes operations**
- Evaluate tools commonly used in enterprise environments
- Create reproducible, reviewable examples for technical interviews and assessments

This is **not a toy project** — the focus is on **real-life patterns**, trade-offs, and automation.

---

## 🧱 Platforms & Environments

The lab is structured by **platform**, allowing each environment to be developed independently while following similar design principles.

### Current
- **Proxmox (On-prem / Home Lab)** – primary active environment

### Planned
- **AWS**
- **Azure**
- **Oracle Cloud (OCI)**

Each platform will live at the same directory level to keep concerns separated and comparable.

```

.
├── proxmox/
├── aws/        (planned)
├── azure/      (planned)
└── oracle/     (planned)

```

---

## 🛠️ Tooling & Technologies

This project intentionally uses tools that are widely adopted in real-world DevOps teams:

### Infrastructure & Configuration
- **Terraform** – infrastructure provisioning
- **Ansible** – configuration management
- **Proxmox** – virtualization platform
- **Kubernetes (k8s)** – container orchestration

### CI/CD & Artifact Management
- **Jenkins** – CI/CD pipelines
- **Docker** – containerization
- **Nexus Repository** – artifact & image registry

### Observability & Operations
- **Prometheus** – metrics & monitoring
- **Grafana** – visualization & dashboards

### Quality & Security (ongoing / planned)
- Code quality analysis tools
- Container image scanning
- Vulnerability and security checks
- Policy and best-practice validation

---

## 🔄 End-to-End Workflow (High Level)

The lab aims to automate the full lifecycle:

1. **Design & planning**
2. **Provision infrastructure** (Terraform)
3. **Configure systems** (Ansible)
4. **Deploy Kubernetes cluster**
5. **Build application artifacts**
6. **Run CI/CD pipelines** (Jenkins/Gitlabs/Github Actions)
7. **Test & validate**
8. **Push Docker images to Nexus**
9. **Deploy to Kubernetes**
10. **Monitor with Prometheus & Grafana**
11. **Upgrade, scale, and iterate**

---

## 📁 Current Project Structure

```

proxmox/
├── terraform/            # Infrastructure provisioning
├── ansible/              # Configuration management
├── k8s/                  # Kubernetes manifests & configs
├── Jenkinsfile.cicd      # CI/CD pipeline definition
├── phase1-static-site/   # Example application workload
├── scripts/              # Helper and automation scripts
├── docs/                 # Design and documentation
├── devops_lab.md         # Detailed lab explanation
├── upgradeplan.md        # Upgrade and evolution plan
├── QUICK_REFERENCE.md    # Commands & quick notes
└── readme.md             # Proxmox-specific documentation

```

Each platform directory contains its own documentation and implementation details.

---

## 📚 Documentation Philosophy

- **Why > What > How**
- Design decisions are documented
- Trade-offs are explained
- Commands alone are not enough — reasoning matters

This makes the project easier to review, extend, and discuss in technical interviews.

---

## 👤 Author & Attribution

This project is designed and implemented by **Laxman** as part of a personal DevOps and Kubernetes learning initiative.

You are welcome to:
- Review the code
- Run the lab
- Fork the repository for learning or evaluation purposes

You may **not** present this project as your own original work in resumes, portfolios, or job applications.  
Any forks or derivative work should provide **clear attribution** to the original author.

---

## 📄 License

This repository is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

## 🚧 Project Status

This is an **actively evolving lab**.  
Expect changes, refactoring, and new platforms to be added over time as the project grows.

---

## 💬 Feedback & Discussion

Feedback, suggestions, and technical discussions are welcome.  
The goal of this project is continuous improvement — both technically and operationally.
```
