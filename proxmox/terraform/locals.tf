################################################################################
# LOCAL VALUES
# Centralized locals for the Terraform module
################################################################################

locals {
  # Proxmox LXC tags are comma-separated strings
  tags = "${var.environment},${var.project_name},terraform"

  k8s_cluster_name = "${var.project_name}-cluster"

  ansible_user = "ubuntu"
}
