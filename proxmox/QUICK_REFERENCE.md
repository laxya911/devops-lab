## File 23: `QUICK_REFERENCE.md` (Quick Reference Guide)

```markdown
# Quick Reference - Kubernetes DevOps Lab

## Directory Structure
```

k8s-devops-lab/
├── terraform/ # Infrastructure as Code
├── ansible/ # Configuration Management
├── scripts/ # Automation scripts
└── docs/ # Documentation

````

## Common Commands

### Terraform

```bash
cd terraform

# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy -auto-approve

# Show outputs
terraform output
terraform output -json > ../outputs.json
````

### Ansible

```bash
cd ansible

# Check syntax
ansible-playbook --syntax-check playbooks/*.yml

# Run playbook
ansible-playbook -i inventory.ini playbooks/01-prepare.yml

# Run specific host
ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml -l kube-master

# Dry run
ansible-playbook -i inventory.ini playbooks/*.yml --check

# Verbose output
ansible-playbook -i inventory.ini playbooks/*.yml -vv
```

### Kubernetes

```bash
# Get resources
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get deploy -A

# Describe resource
kubectl describe node kube-master
kubectl describe pod <pod-name> -n default

# View logs
kubectl logs <pod-name> -n default
kubectl logs -f <pod-name> -n default  # Follow

# Execute command
kubectl exec -it <pod-name> -n default -- /bin/bash

# Port forward
kubectl port-forward pod/<pod-name> 8080:8080

# Scale deployment
kubectl scale deployment <name> --replicas=3

# Delete resource
kubectl delete pod <pod-name>
kubectl delete deployment <name>
```

### SSH Access

```bash
# Master
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10

# Worker 1
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.20

# Worker 2
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.30

# Jenkins
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Monitoring
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.50
```

## Instance IPs

| Instance   | Private IP | Service                |
| ---------- | ---------- | ---------------------- |
| Master     | 10.0.1.10  | K8s API, etcd, Kubelet |
| Worker 1   | 10.0.1.20  | Kubelet, Pods          |
| Worker 2   | 10.0.1.30  | Kubelet, Pods          |
| CI/CD      | 10.0.1.40  | Jenkins, Nexus         |
| Monitoring | 10.0.1.50  | Prometheus, Grafana    |

## Service Ports

| Service        | Port      | Access   |
| -------------- | --------- | -------- |
| Kubernetes API | 6443      | Internal |
| Jenkins        | 8080      | Public   |
| Nexus          | 8081      | Public   |
| Prometheus     | 9090      | Internal |
| Grafana        | 3000      | Public   |
| Node Exporter  | 9100      | Internal |
| Kubelet        | 10250     | Internal |
| etcd           | 2379-2380 | Internal |

## File Locations

### On Master

- `/etc/rancher/k3s/k3s.yaml` - kubeconfig
- `/var/lib/rancher/k3s/` - K3s data
- `/var/lib/rancher/k3s/server/node-token` - Worker token

### On Jenkins

- `/var/lib/jenkins/` - Jenkins home
- `/opt/nexus/data/` - Nexus data
- `/var/lib/jenkins/secrets/initialAdminPassword` - Jenkins admin password

### On Monitoring

- `/etc/prometheus/prometheus.yml` - Prometheus config
- `/var/lib/prometheus/` - Prometheus data
- `/etc/grafana/provisioning/` - Grafana config
- `/var/lib/grafana/` - Grafana data

## Resource Limits (Free Tier)

- Total OCPU: 4
- Total Memory: 24GB
- Total Storage: 200GB
- Instances: 5 (3 Ampere A1.Flex + 2 E2 Micro)

## Playbook Execution Order

1. `01-prepare.yml` - Base system setup (all hosts)
2. `02-k3s-master.yml` - Kubernetes master
3. `03-k3s-worker.yml` - Kubernetes workers
4. `04-jenkins-nexus.yml` - CI/CD stack
5. `05-monitoring.yml` - Monitoring stack

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgn='kubectl get nodes'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
```

## Common Issues & Solutions

| Issue                  | Solution                                                         |
| ---------------------- | ---------------------------------------------------------------- |
| SSH timeout            | Wait 2-3 min for instances to boot                               |
| K3s not starting       | Check logs: `journalctl -u k3s -f`                               |
| Worker not joining     | Verify token on master: `/var/lib/rancher/k3s/server/node-token` |
| Jenkins not accessible | Check firewall: `sudo ufw status`                                |
| Prometheus no data     | Verify targets: `http://localhost:9090/api/v1/targets`           |
| High memory usage      | Check resource limits: `kubectl top nodes`                       |
| Disk full              | Check storage: `df -h`                                           |

## Monitoring Checklist

- [ ] All instances running
- [ ] All nodes joined K3s cluster
- [ ] Jenkins accessible and plugins installed
- [ ] Nexus accessible and configured
- [ ] Prometheus scraping targets
- [ ] Grafana dashboards configured
- [ ] Node exporters reporting metrics
- [ ] Storage not exceeding 200GB
- [ ] Memory not exceeding 24GB
