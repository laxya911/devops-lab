# Quick Reference - Kubernetes DevOps Lab


k8s-devops-lab/
├── terraform/ # Infrastructure as Code
├── ansible/ # Configuration Management
├── scripts/ # Automation scripts
└── docs/ # Documentation

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

### Ansible

# Check syntax
ansible-playbook --syntax-check playbooks/*.yml

# Run playbook
ansible-playbook -i inventory.ini playbooks/01-prepare.yml

# Run specific host
ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml -l kube-master


### Kubernetes
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

### SSH Access
ssh -i ~/.ssh/id_rsa ubuntu@ip_address

# Worker 1
ssh -i ~/.ssh/id_rsa ubuntu@ip_address

# Worker 2
ssh -i ~/.ssh/id_rsa ubuntu@ip_address

# Jenkins
ssh -i ~/.ssh/id_rsa ubuntu@ip_address

# Monitoring
ssh -i ~/.ssh/id_rsa ubuntu@ip_address

## Instance IPs

| Instance   | Private IP | Service                |
| ---------- | ---------- | ---------------------- |
| Master     | ip_address  | K8s API, etcd, Kubelet |
| Worker 1   | ip_address  | Kubelet, Pods          |
| Worker 2   | ip_address  | Kubelet, Pods          |
| CI/CD      | ip_address  | Jenkins, Nexus         |
| Monitoring | ip_address  | Prometheus, Grafana    |

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
