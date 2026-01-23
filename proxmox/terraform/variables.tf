################################################################################
# TERRAFORM VARIABLES
# All input parameters for infrastructure customization
################################################################################

# ============================================================================
# PROXMOX AUTHENTICATION VARIABLES
# ============================================================================

variable "pm_api_url" {
  description = "Proxmox API URL (e.g., https://192.168.0.20:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Proxmox User (e.g., root@pam)"
  type        = string
  default     = "" # Optional when using Token
}

variable "pm_password" {
  description = "Proxmox Password"
  type        = string
  sensitive   = true
  default     = "" # Optional when using Token
}

variable "pm_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  default     = ""
}

variable "pm_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "target_node" {
  description = "Proxmox Node Name (e.g., pve)"
  type        = string
  default     = "pve"
}

variable "storage_pool" {
  description = "Proxmox Storage to use for containers (e.g., local-lvm or nvme-storage)"
  type        = string
  default     = "nvme-storage"
}

# ============================================================================
# NETWORK & SSH VARIABLES
# ============================================================================

variable "ssh_public_key" {
  description = "SSH public key for container access (paste entire key content)"
  type        = string
  sensitive   = true
}

variable "gateway" {
  description = "Network Gateway IP"
  type        = string
  default     = "192.168.0.1"
}

# ============================================================================
# CONTAINER OS TEMPLATE
# ============================================================================

variable "template_name" {
  description = "VM Template Name (Cloud-Init enabled)"
  type        = string
  default     = "ubuntu-2404-cloud-template"
}

# ============================================================================
# CONTAINER RESOURCES (CPU/RAM/IP)
# ============================================================================

# ---- MASTER ----
variable "kube_master_hostname" {
  description = "Hostname for Master"
  default     = "kube-master"
}
variable "kube_master_cores" {
  description = "CPU Cores for Master"
  default     = 2
}
variable "kube_master_memory" {
  description = "RAM (MB) for Master"
  default     = 4096
}
variable "kube_master_vmid" {
  description = "VMID for Master"
  default     = 210
}
variable "kube_master_ip" {
  description = "IP/CIDR for Master (or 'dhcp')"
  default     = "dhcp"
}

# ---- WORKER 1 ----
variable "kube_worker_1_hostname" {
  default = "kube-worker-1"
}
variable "kube_worker_1_cores" {
  default = 2
}
variable "kube_worker_1_memory" {
  default = 4096
}
variable "kube_worker_1_vmid" {
  default = 211
}
variable "kube_worker_1_ip" {
  default = "dhcp"
}

# ---- WORKER 2 ----
variable "kube_worker_2_hostname" {
  default = "kube-worker-2"
}
variable "kube_worker_2_cores" {
  default = 2
}
variable "kube_worker_2_memory" {
  default = 4096
}
variable "kube_worker_2_vmid" {
  default = 212
}
variable "kube_worker_2_ip" {
  default = "dhcp"
}

# ---- JENKINS ----
variable "jenkins_nexus_hostname" {
  default = "jenkins-nexus"
}
variable "jenkins_nexus_cores" {
  default = 2
}
variable "jenkins_nexus_memory" {
  default = 8192
}
variable "jenkins_nexus_vmid" {
  default = 213
}
variable "jenkins_nexus_ip" {
  default = "dhcp"
}

# ============================================================================
# TAGGING VARIABLES (Restored)
# ============================================================================

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "k8s-devops-lab"
}

variable "created_by" {
  description = "Creator identifier"
  type        = string
  default     = "terraform"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "provision_user" {
  description = "User to be used by Ansible for provisioning"
  type        = string
  default     = "ansible"
}

variable "ssh_password" {
  description = "Optional SSH password for cloud-init user (leave empty to disable)"
  type        = string
  sensitive   = true
  default     = ""
}
