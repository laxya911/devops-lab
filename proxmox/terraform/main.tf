################################################################################
# MAIN TERRAFORM FILE - ENTRY POINT
# This is the primary orchestration file that brings together all resources
# All .tf files in this directory are processed by Terraform in alphabetical order
# main.tf is conventionally the entry point for understanding the infrastructure
################################################################################

/* Provider, data sources and locals moved to provider.tf and variables.tf.
   Keep this file as documentation/entrypoint. */

# ============================================================================
# RESOURCE CREATION
# ============================================================================

# Network Infrastructure (vpc.tf)
# - Virtual Cloud Network (VCN)
# - Subnets
# - Internet Gateway
# - Route Tables
# - Network Security Groups (Firewalls)

# Compute Instances (instances.tf)
# - Kubernetes Master (kube-master)
# - Kubernetes Worker 1 (kube-worker-1)
# - Kubernetes Worker 2 (kube-worker-2)
# - CI/CD Stack (jenkins-nexus)
# - Monitoring Stack (monitoring)

# ============================================================================
# INFRASTRUCTURE SUMMARY
# ============================================================================
# 
# This Terraform configuration creates a complete Kubernetes DevOps lab on
# Oracle Cloud Free Tier with the following components:
#
# NETWORK:
# - 1 Virtual Cloud Network (VCN)
# - 1 Subnet with dynamic host addressing
# - 1 Internet Gateway for external access
# - 4 Network Security Groups (for different service types)
# - Proper routing and firewall rules
#
# COMPUTE INSTANCES:
# - 1 Kubernetes Master (Ampere A1.Flex: 1.5 OCPU, 8GB RAM)
# - 2 Kubernetes Workers (A1.Flex: 1 OCPU/6GB + E2.Micro: 1/8 OCPU/1GB)
# - 1 CI/CD Stack (Jenkins + Nexus) (Ampere A1.Flex: 1 OCPU, 8GB RAM)
# - 1 Monitoring Stack (Prometheus + Grafana) (E2.Micro: 1/8 OCPU, 1GB RAM)
#
# STORAGE:
# - 5 Boot volumes (197GB total, within 200GB free tier limit)
# - Preserved on instance termination for data safety
#
# RESOURCE ALLOCATION:
# - Total OCPU: 3.75 (within 4 OCPU free tier limit)
# - Total Memory: 24GB (within 24GB free tier limit)
# - Total Storage: 197GB (within 200GB free tier limit)
#
# COST: $0/month (Oracle Cloud Always Free tier)
#
# ============================================================================

# ============================================================================
# OUTPUT SECTION
# ============================================================================
# All outputs are defined in outputs.tf
# Key outputs include:
# - Instance IP addresses (private and public)
# - Service URLs (Jenkins, Grafana, Prometheus)
# - Kubernetes cluster information
# - SSH connection commands
# - Resource summary
#
# View outputs with: terraform output
# ============================================================================

# ============================================================================
# DEPLOYMENT INSTRUCTIONS
# ============================================================================
#
# 1. Initialize Terraform
#    $ terraform init
#
# 2. Validate configuration
#    $ terraform validate
#
# 3. Format code
#    $ terraform fmt
#
# 4. Create plan
#    $ terraform plan -out=tfplan
#
# 5. Review plan and apply
#    $ terraform apply tfplan
#
# 6. Get outputs
#    $ terraform output
#
# 7. Update Ansible inventory with instance IPs
#    $ cd ../ansible && nano inventory.ini
#
# 8. Run Ansible playbooks
#    $ ansible-playbook -i inventory.ini playbooks/01-prepare.yml
#    $ ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml
#    $ ansible-playbook -i inventory.ini playbooks/03-k3s-worker.yml
#    $ ansible-playbook -i inventory.ini playbooks/04-jenkins-nexus.yml
#    $ ansible-playbook -i inventory.ini playbooks/05-monitoring.yml
#
# 9. Verify deployment
#    $ bash ../scripts/validate.sh
#
# 10. Cleanup (when done)
#     $ terraform destroy -auto-approve
#
# ============================================================================

# ============================================================================
# FILE REFERENCE GUIDE
# ============================================================================
#
# main.tf              ← You are here (entry point and overview)
# provider.tf          ← OCI provider configuration
# variables.tf         ← Input variable definitions
# vpc.tf               ← Network infrastructure (VCN, subnets, security groups)
# instances.tf         ← Compute instance definitions
# outputs.tf           ← Output values and connection information
# terraform.tfvars     ← Your configuration values (DO NOT COMMIT)
# terraform.tfvars.example ← Template for terraform.tfvars
# .gitignore          ← Git ignore rules (protects sensitive files)
#
# ============================================================================

# ============================================================================
# QUICK COMMANDS REFERENCE
# ============================================================================
#
# Show current state:
#   terraform show
#
# Show specific resource:
#   terraform state show oci_core_instance.kube_master
#
# Refresh state:
#   terraform refresh
#
# Plan destroy:
#   terraform plan -destroy
#
# Destroy specific resource:
#   terraform destroy -target=oci_core_instance.kube_master
#
# Import existing resource:
#   terraform import oci_core_instance.kube_master <instance-ocid>
#
# Format all files:
#   terraform fmt -recursive
#
# Validate all files:
#   terraform validate
#
# Generate graph (requires graphviz):
#   terraform graph | dot -Tsvg > graph.svg
#
# ============================================================================

# ============================================================================
# TROUBLESHOOTING QUICK LINKS
# ============================================================================
#
# If Terraform initialization fails:
# 1. Check OCI CLI is configured: oci os ns get
# 2. Verify tenancy_ocid in terraform.tfvars
# 3. Check SSH key: ls ~/.ssh/id_rsa
# 4. Verify region: oci regions list
#
# If apply fails:
# 1. Check for quota exceeded: oci limits quota get
# 2. Verify shape availability: oci compute shape list
# 3. Check compartment access: oci iam compartment list
# 4. Review security: oci compute instance list
#
# For detailed error logs:
#   TF_LOG=DEBUG terraform apply tfplan
#
# ============================================================================
