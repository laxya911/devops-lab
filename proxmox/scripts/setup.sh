#!/bin/bash
################################################################################
# KUBERNETES DEVOPS LAB - SETUP SCRIPT
# This script initializes your local environment for Terraform deployment
################################################################################

set -e

echo "================================"
echo "K8s DevOps Lab - Setup Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running from correct directory
if [ ! -d "terraform" ]; then
    echo -e "${RED}Error: terraform directory not found!${NC}"
    echo "Please run this script from the k8s-devops-lab directory"
    exit 1
fi

echo -e "${GREEN}✓ Found terraform directory${NC}"
echo ""

# Check for required tools
echo "Checking required tools..."
echo ""

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ Terraform is not installed${NC}"
    echo "Install from: https://www.terraform.io/downloads.html"
    exit 1
fi
echo -e "${GREEN}✓ Terraform $(terraform version -json | grep terraform_version | cut -d'"' -f4)${NC}"

# Check OCI CLI
if ! command -v oci &> /dev/null; then
    echo -e "${RED}✗ OCI CLI is not installed${NC}"
    echo "Install from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
fi
echo -e "${GREEN}✓ OCI CLI installed${NC}"

# Check SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${RED}✗ SSH key not found at ~/.ssh/id_rsa${NC}"
    echo "Generate with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
    exit 1
fi
echo -e "${GREEN}✓ SSH key found${NC}"

# Check OCI config
if [ ! -f ~/.oci/config ]; then
    echo -e "${RED}✗ OCI config not found at ~/.oci/config${NC}"
    echo "Please configure OCI CLI first"
    exit 1
fi
echo -e "${GREEN}✓ OCI config found${NC}"
echo ""

# Initialize Terraform
echo "Initializing Terraform..."
cd terraform

if terraform init; then
    echo -e "${GREEN}✓ Terraform initialized${NC}"
else
    echo -e "${RED}✗ Terraform initialization failed${NC}"
    exit 1
fi

echo ""
echo "================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Edit terraform/terraform.tfvars with your values:"
echo "   - Replace tenancy_ocid with your actual OCID"
echo "   - Replace ssh_public_key with your SSH public key"
echo ""
echo "2. Validate configuration:"
echo "   terraform validate"
echo ""
echo "3. Plan deployment:"
echo "   terraform plan -out=tfplan"
echo ""
echo "4. Apply configuration:"
echo "   terraform apply tfplan"
echo ""
