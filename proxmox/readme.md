# Kubernetes DevOps Lab - Oracle Cloud Free Tier

Complete Infrastructure as Code setup using Terraform + Ansible for a production-ready Kubernetes testing lab on Oracle Cloud Free Tier.

## Quick Start (5 minutes)

```bash
# 1. Clone or setup directory
mkdir -p ~/k8s-devops-lab
cd ~/k8s-devops-lab

# 2. Copy terraform files
mkdir -p terraform scripts ansible
# ... copy all .tf files to terraform/
# ... copy all .sh files to scripts/
# ... copy all .yml files to ansible/

# 3. Setup environment
bash scripts/setup.sh

# 4. Configure values
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform/terraform.tfvars with your tenancy OCID and SSH key

# 5. Deploy infrastructure
bash scripts/deploy.sh

# 6. Verify setup (wait 2-3 minutes after terraform)
bash scripts/validate.sh


k8s-devops-lab/
├── terraform/
│   ├── provider.tf           # OCI provider config
│   ├── variables.tf          # Variable definitions
│   ├── vpc.tf                # Network configuration
│   ├── instances.tf          # Compute instances
│   ├── outputs.tf            # Output values
│   ├── terraform.tfvars      # Your values (DO NOT COMMIT)
│   ├── terraform.tfvars.example  # Template
│   └── .gitignore            # Protect sensitive files
│
├── ansible/
│   ├── inventory.ini         # Host inventory
│   ├── ansible.cfg           # Ansible config
│   ├── playbooks/
│   │   ├── 01-prepare.yml         # Base system setup
│   │   ├── 02-k3s-master.yml      # K3s master
│   │   ├── 03-k3s-worker.yml      # K3s workers
│   │   ├── 04-jenkins-nexus.yml   #
