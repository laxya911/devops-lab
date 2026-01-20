#!/bin/bash
################################################################################
# KUBERNETES DEVOPS LAB - DEPLOYMENT SCRIPT
# Deploys infrastructure and runs Ansible playbooks
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════╗"
echo "║   K8s DevOps Lab - Full Deployment                ║"
echo "║   Terraform + Ansible                             ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Step 1: Validate Terraform
echo -e "${BLUE}[1/4] Validating Terraform configuration...${NC}"
cd terraform
terraform validate
echo -e "${GREEN}✓ Terraform validation passed${NC}"
echo ""

# Step 2: Plan Terraform
echo -e "${BLUE}[2/4] Creating Terraform plan...${NC}"
terraform plan -out=tfplan
echo -e "${GREEN}✓ Terraform plan created${NC}"
echo ""

# Step 3: Apply Terraform
echo -e "${BLUE}[3/4] Applying Terraform configuration (Creating infrastructure)...${NC}"
echo -e "${YELLOW}This will create 5 instances. Continue? (yes/no)${NC}"
read -r response
if [ "$response" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

terraform apply tfplan
echo -e "${GREEN}✓ Infrastructure created${NC}"
echo ""

# Step 4: Get outputs
echo -e "${BLUE}[4/4] Retrieving instance information...${NC}"
terraform output -json > outputs.json
echo -e "${GREEN}✓ Outputs saved${NC}"
echo ""

# Display connection information
echo -e "${GREEN}"
echo "════════════════════════════════════════════════════"
echo "Deployment Complete!"
echo "════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "Instance Details:"
terraform output kubernetes_cluster_info
echo ""
echo "SSH Connection Commands:"
terraform output ssh_connection_commands
echo ""
echo -e "${YELLOW}Note: Instances are starting. Wait 2-3 minutes before SSH connection.${NC}"
echo ""
echo "Next steps:"
echo "1. Wait for instances to fully boot (~2-3 minutes)"
echo "2. Run Ansible playbooks: cd ../ansible && ansible-playbook -i inventory.ini 01-prepare.yml"
echo ""
