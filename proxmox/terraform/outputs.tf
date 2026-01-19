################################################################################
# TERRAFORM OUTPUTS
# Useful information displayed after deployment
################################################################################

# output "master_ip" {
#   value = var.kube_master_ip
# }

# output "worker_1_ip" {
#   value = var.kube_worker_1_ip
# }

# output "worker_2_ip" {
#   value = var.kube_worker_2_ip
# }

# output "jenkins_ip" {
#   value = var.jenkins_nexus_ip
# }

# output "master_ssh_command" {
#   value = "ssh terraform@${split("/", var.kube_master_ip)[0]}"
# }


output "vm_names" {
  value = [
    proxmox_vm_qemu.kube_master.name,
    proxmox_vm_qemu.kube_worker_1.name,
    proxmox_vm_qemu.kube_worker_2.name,
    proxmox_vm_qemu.jenkins_nexus.name
  ]
}

output "vm_gateways" {
  value = [
    "192.168.0.1",
    "192.168.0.1",
    "192.168.0.1",
    "192.168.0.1"
  ]
}

# output "vm_ips" {
#   value = [
#     proxmox_vm_qemu.kube_master.default_ipv4_address,
#     proxmox_vm_qemu.kube_worker_1.default_ipv4_address,
#     proxmox_vm_qemu.kube_worker_2.default_ipv4_address,
#     proxmox_vm_qemu.jenkins_nexus.default_ipv4_address
#   ]
# }

output "vm_ips" {
  value = [
    proxmox_vm_qemu.kube_master.default_ipv4_address,
    proxmox_vm_qemu.kube_worker_1.default_ipv4_address,
    proxmox_vm_qemu.kube_worker_2.default_ipv4_address,
    proxmox_vm_qemu.jenkins_nexus.default_ipv4_address
  ]
}

output "ssh_commands" {
  value = [
    "ssh ${var.ssh_user}@${proxmox_vm_qemu.kube_master.default_ipv4_address}",
    "ssh ${var.ssh_user}@${proxmox_vm_qemu.kube_worker_1.default_ipv4_address}",
    "ssh ${var.ssh_user}@${proxmox_vm_qemu.kube_worker_2.default_ipv4_address}",
    "ssh ${var.ssh_user}@${proxmox_vm_qemu.jenkins_nexus.default_ipv4_address}"
  ]
}

