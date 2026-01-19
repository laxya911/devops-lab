################################################################################
# VIRTUAL CLOUD NETWORK (VCN) AND NETWORKING CONFIGURATION
# NOTE: Networking is offloaded to Proxmox Host Bridge (vmbr0)
################################################################################

# ============================================================================
# VIRTUAL CLOUD NETWORK (VCN)
# ============================================================================

# We are using QEMU VMs which are bridged directly to the physical network 
# (or vmbr0) of the Proxmox node.
# Therefore, no VCN, Subnet, or Route Table resources are needed here.
# Networking is defined inside 'instances.tf' using the 'network' block.
