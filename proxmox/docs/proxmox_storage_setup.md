# 📘 Proxmox: Adding a New Disk as Default VM / Container Storage

This document describes a **generic, repeatable process** to:

- Discover a newly attached disk
- Inspect existing partitions and data
- Safely wipe the disk
- Configure it as **LVM-thin storage**
- Make it the **default storage** for all new VMs and containers
- Safely **roll back or remove the disk** later if needed

The disk can be **NVMe, SATA SSD, or HDD**.  
Only device names and sizes differ.

---

## 📑 Table of Contents

1. [Assumptions](#assumptions)
2. [Warning](#warning)

### Beginner Section

3. [Discover Disks](#discover-disks)
4. [Inspect Disk Structure & Filesystems](#inspect-disk-structure--filesystems)
5. [Mount and Inspect Existing Data (Optional)](#mount-and-inspect-existing-data-optional)
6. [Wipe Existing Signatures](#wipe-existing-signatures)
7. [Create LVM Thin Pool](#create-lvm-thin-pool)
8. [Register Storage in Proxmox](#register-storage-in-proxmox)
9. [Make Storage Default for New VMs & Containers](#make-storage-default-for-new-vms--containers)
10. [Validate Default Storage Selection](#validate-default-storage-selection)

### Advanced Section

11. [Containers (CT) Example](#containers-ct-example)
12. [Best Practices](#best-practices)
13. [Disk Removal / Rollback Procedure](#disk-removal--rollback-procedure)
14. [Result](#result)

---

## 🧩 Assumptions

- Proxmox VE 8+ 9+
- Tested on VE 9+
- Root access on the Proxmox host
- Existing Proxmox OS disk already configured
- New disk is **not currently used by Proxmox**

---

## ⚠️ Warning

> **All wipe, LVM, and rollback steps are destructive**  
> Ensure you have copied or migrated any required data before proceeding.

---

# 🟢 Beginner Section

These steps are sufficient for **most users** and cover the full setup.

---

## 🔍 Discover Disks

List all block devices:

```bash
lsblk
```

Example output:

```
NAME        SIZE TYPE
sda       238.5G disk   ← Proxmox OS disk
nvme0n1   931.5G disk   ← NEW disk (example)
```

👉 Identify the new disk and replace `<DISK>` accordingly:

- `/dev/nvme0n1`
- `/dev/sdb`
- `/dev/sdc`

---

## 🧪 Inspect Disk Structure & Filesystems

```bash
lsblk -f /dev/<DISK>
fdisk -l /dev/<DISK>
```

Possible findings:

- `ntfs` → old Windows disk
- `ext4`, `xfs` → Linux data
- `lvm2_member`, `zfs_member`
- empty → unused disk

---

## 📂 Mount and Inspect Existing Data (Optional)

Only do this if data may be useful.

```bash
mkdir /mnt/disk-check
mount /dev/<DISK_PARTITION> /mnt/disk-check
ls -lah /mnt/disk-check
umount /mnt/disk-check
```

---

## 🧹 Wipe Existing Signatures

```bash
wipefs -a /dev/<DISK>
```

Create a new GPT partition:

```bash
parted /dev/<DISK> --script \
  mklabel gpt \
  mkpart primary 0% 100%
```

Remove leftover signatures:

```bash
wipefs -a /dev/<DISK>p1
partprobe /dev/<DISK>
```

Verify:

```bash
lsblk -f /dev/<DISK>
```

---

## 🧱 Create LVM Thin Pool

```bash
pvcreate /dev/<DISK>p1
vgcreate <VG_NAME> /dev/<DISK>p1
lvcreate -l 100%FREE -T <VG_NAME>/<THINPOOL_NAME>
```

Verify:

```bash
lvs
```

---

## ➕ Register Storage in Proxmox

```bash
pvesm add lvmthin <STORAGE_NAME> \
  --vgname <VG_NAME> \
  --thinpool <THINPOOL_NAME> \
  --content images,rootdir
```

---

## ⭐ Make Storage Default for New VMs & Containers

Edit:

```bash
nano /etc/pve/storage.cfg
```

Ensure new storage appears **before** `local-lvm`:

```ini
lvmthin: <STORAGE_NAME>
        vgname <VG_NAME>
        thinpool <THINPOOL_NAME>
        content images,rootdir
```

✔ Order matters
✔ No restart required
✔ Existing VMs remain untouched

---

## 🧪 Validate Default Storage Selection

```bash
qm create <VMID> --name storage-test --memory 256 --net0 virtio,bridge=vmbr0
qm set <VMID> --scsi0 <STORAGE_NAME>:4
qm config <VMID> | grep scsi
qm destroy <VMID>
```

---

# 🔵 Advanced Section

This section is useful for **automation-heavy**, **test environments**, and **long-term maintenance**.

---

## 📦 Containers (CT) Example

```bash
pct create <CTID> local:vztmpl/debian-12-standard.tar.zst \
  --rootfs <STORAGE_NAME>:8 \
  --hostname test-ct
```

---

## 🔧 Best Practices

- Keep thin pool usage **below 80–85%**
- Enable TRIM / discard:

```bash
lvchange --discard passdown <VG_NAME>/<THINPOOL_NAME>
systemctl enable fstrim.timer
```

- Always specify storage explicitly in Terraform / Ansible
- Monitor usage:

```bash
watch pvesm status
```

---

## 🔄 Disk Removal / Rollback Procedure

Use this section if you need to **remove the disk**, **replace it**, or **undo this setup**.

---

### Step 1: Migrate or Remove VMs / Containers

List disks using the storage:

```bash
pvesm list <STORAGE_NAME>
```

Migrate VMs if needed:

```bash
qm move_disk <VMID> scsi0 <TARGET_STORAGE> --online
```

Or destroy test VMs:

```bash
qm destroy <VMID>
pct destroy <CTID>
```

---

### Step 2: Remove Storage from Proxmox

```bash
pvesm remove <STORAGE_NAME>
```

---

### Step 3: Restore Default Storage Order

Edit:

```bash
nano /etc/pve/storage.cfg
```

Ensure `local-lvm` comes before the removed storage.

---

### Step 4: Remove LVM Structures

```bash
lvremove <VG_NAME>/<THINPOOL_NAME>
vgremove <VG_NAME>
pvremove /dev/<DISK>p1
```

---

### Step 5: (Optional) Wipe Disk Completely

```bash
wipefs -a /dev/<DISK>
```

Disk is now safe to:

- Reuse
- Replace
- Remove from the system

---

## ✅ Result

- New disk safely integrated into Proxmox
- All **new VMs & containers** use it by default
- Existing workloads unaffected
- Clean rollback path documented
- Suitable for testing, automation, and production labs

```

```
