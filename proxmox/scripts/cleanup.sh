#!/bin/bash
################################################################################
# CLEANUP SCRIPT
# Destroys all Terraform-managed infrastructure
# WARNING: This will delete all instances and volumes!
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════╗"
echo "║   K8s DevOps Lab - Cleanup Script                 ║"
echo "║   WARNING: This will DELETE all resources!        ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

cd terraform

# Show what will be destroyed
echo -e "${YELLOW}Resources that will be DELETED:${NC}"
terraform plan -destroy | grep "  - " | head -20
echo ""

# Confirm deletion
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo "Type 'yes, destroy all' to confirm:"
read -r confirmation

if [ "$confirmation" != "yes, destroy all" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo -e "${BLUE}Destroying infrastructure...${NC}"

if terraform destroy -auto-approve; then
    echo -e "${GREEN}✓ Infrastructure destroyed${NC}"
else
    echo -e "${RED}✗ Destruction failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Clean up local files: rm -f tfplan terraform.tfstate* outputs.json"
echo "2. Clean up SSH known_hosts: ssh-keygen -R <instance-ip>"
echo ""
