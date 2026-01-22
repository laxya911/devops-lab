################################################################################
# PROXMOX VM CONFIGURATION (QEMU/KVM)
# Creates 4 VMs for Kubernetes DevOps Lab
################################################################################

# ============================================================================
# INSTANCE 1: KUBERNETES MASTER NODE
# ============================================================================

resource "proxmox_vm_qemu" "kube_master" {
  target_node = var.target_node
  vmid        = var.kube_master_vmid
  name        = var.kube_master_hostname
  clone       = var.template_name
  full_clone  = true

  # Cloud-init disk storage
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "ide2"
  }

  # System Config
  agent   = 1
  os_type = "cloud-init"

  cpu {
    cores   = var.kube_master_cores
    sockets = 1
    type    = "host"
  }

  memory   = var.kube_master_memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  # Cloud-Init
  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  # Static IP from variables.tf/terraform.tfvars
  # Example: kube_master_ip = "192.168.0.30/24"
  ipconfig0 = "ip=${var.kube_master_ip},gw=${var.gateway}"

  # Disk Override (Template has smaller disk)
  disk {
    slot    = "scsi0"
    size    = "30G"
    type    = "disk"
    storage = var.storage_pool
  }

  # Network
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Meta
  tags = "terraform,k8s-devops-lab,dev"
}

# ============================================================================
# INSTANCE 2: KUBERNETES WORKER NODE 1
# ============================================================================

resource "proxmox_vm_qemu" "kube_worker_1" {
  target_node = var.target_node
  vmid        = var.kube_worker_1_vmid
  name        = var.kube_worker_1_hostname
  clone       = var.template_name
  full_clone  = true
  # Cloud-init disk storage
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "ide2"
  }
  agent   = 1
  os_type = "cloud-init"

  cpu {
    cores   = var.kube_worker_1_cores
    sockets = 1
    type    = "host"
  }

  memory   = var.kube_worker_1_memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  # Static IP
  ipconfig0 = "ip=${var.kube_worker_1_ip},gw=${var.gateway}"

  disk {
    slot    = "scsi0"
    size    = "30G"
    type    = "disk"
    storage = var.storage_pool
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  tags = "terraform,k8s-devops-lab,dev"
}

# ============================================================================
# INSTANCE 3: KUBERNETES WORKER NODE 2
# ============================================================================

resource "proxmox_vm_qemu" "kube_worker_2" {
  target_node = var.target_node
  vmid        = var.kube_worker_2_vmid
  name        = var.kube_worker_2_hostname
  clone       = var.template_name
  full_clone  = true
  # Cloud-init disk storage
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "ide2"
  }
  agent   = 1
  os_type = "cloud-init"

  cpu {
    cores   = var.kube_worker_2_cores
    sockets = 1
    type    = "host"
  }

  memory   = var.kube_worker_2_memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  # Static IP
  ipconfig0 = "ip=${var.kube_worker_2_ip},gw=${var.gateway}"

  disk {
    slot    = "scsi0"
    size    = "30G"
    type    = "disk"
    storage = var.storage_pool
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  tags = "terraform,k8s-devops-lab,dev"
}

# ============================================================================
# INSTANCE 4: CI/CD (JENKINS + NEXUS)
# ============================================================================

resource "proxmox_vm_qemu" "jenkins_nexus" {
  target_node = var.target_node
  vmid        = var.jenkins_nexus_vmid
  name        = var.jenkins_nexus_hostname
  clone       = var.template_name
  full_clone  = true
  # Cloud-init disk storage
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "ide2"
  }
  agent   = 1
  os_type = "cloud-init"

  cpu {
    cores   = var.jenkins_nexus_cores
    sockets = 1
    type    = "host"
  }

  memory   = var.jenkins_nexus_memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  # Static IP
  ipconfig0 = "ip=${var.jenkins_nexus_ip},gw=${var.gateway}"

  disk {
    slot    = "scsi0"
    size    = "30G"
    type    = "disk"
    storage = var.storage_pool
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  tags = "terraform,k8s-devops-lab,dev"
}


###############################################################################
# WAIT FOR SSH ON ALL VMS
###############################################################################
resource "null_resource" "wait_for_kube_master_ssh" {
  depends_on = [proxmox_vm_qemu.kube_master]

  provisioner "local-exec" {
    command = "sleep 30; for i in $(seq 1 60); do echo 'Waiting for SSH on ${var.kube_master_ip}:22 (try $i)...'; nc -z -w3 ${split("/", var.kube_master_ip)[0]} 22 && exit 0; sleep 10; done; echo 'ERROR: SSH not available on ${var.kube_master_ip}' >&2; exit 1"
  }
}

resource "null_resource" "wait_for_kube_worker_1_ssh" {
  depends_on = [proxmox_vm_qemu.kube_worker_1]

  provisioner "local-exec" {
    command = "for i in $(seq 1 30); do echo 'Waiting for SSH on ${var.kube_worker_1_ip}:22 (try $i)...'; nc -z -w3 ${split("/", var.kube_worker_1_ip)[0]} 22 && exit 0; sleep 10; done; echo 'ERROR: SSH not available on ${var.kube_worker_1_ip}' >&2; exit 1"
  }
}

resource "null_resource" "wait_for_kube_worker_2_ssh" {
  depends_on = [proxmox_vm_qemu.kube_worker_2]

  provisioner "local-exec" {
    command = "for i in $(seq 1 30); do echo 'Waiting for SSH on ${var.kube_worker_2_ip}:22 (try $i)...'; nc -z -w3 ${split("/", var.kube_worker_2_ip)[0]} 22 && exit 0; sleep 10; done; echo 'ERROR: SSH not available on ${var.kube_worker_2_ip}' >&2; exit 1"
  }
}

resource "null_resource" "wait_for_jenkins_nexus_ssh" {
  depends_on = [proxmox_vm_qemu.jenkins_nexus]

  provisioner "local-exec" {
    command = "for i in $(seq 1 30); do echo 'Waiting for SSH on ${var.jenkins_nexus_ip}:22 (try $i)...'; nc -z -w3 ${split("/", var.jenkins_nexus_ip)[0]} 22 && exit 0; sleep 10; done; echo 'ERROR: SSH not available on ${var.jenkins_nexus_ip}' >&2; exit 1"
  }
}


resource "null_resource" "write_ansible_inventory" {
  depends_on = [
    null_resource.wait_for_kube_master_ssh,
    null_resource.wait_for_kube_worker_1_ssh,
    null_resource.wait_for_kube_worker_2_ssh,
    null_resource.wait_for_jenkins_nexus_ssh
  ]

  provisioner "local-exec" {
    command = <<EOT
cat > ../ansible/inventory.ini <<EOF
[all:vars]
ansible_user=${var.ssh_user}
ansible_ssh_private_key_file=${var.ssh_private_key_path}

[kubernetes_master]
kube-master ansible_host=${proxmox_vm_qemu.kube_master.default_ipv4_address}

[kubernetes_workers]
kube-worker-1 ansible_host=${proxmox_vm_qemu.kube_worker_1.default_ipv4_address}
kube-worker-2 ansible_host=${proxmox_vm_qemu.kube_worker_2.default_ipv4_address}

[jenkins_servers]
jenkins-nexus ansible_host=${proxmox_vm_qemu.jenkins_nexus.default_ipv4_address}

[project_lab:children]
kubernetes_master
kubernetes_workers
jenkins_servers
EOF
EOT
  }
}
