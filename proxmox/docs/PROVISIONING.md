# Provisioning & User Strategy

This document explains recommended user/account strategy and the step-by-step workflow from provisioning infrastructure with Terraform to configuring VMs with Ansible.

**Goals**

- Keep the distro default login user (`ubuntu`) as the VM default SSH account.
- Create a separate dedicated sudo user for automation (e.g., `deployer` or `ansible`) used by Ansible.
- Avoid direct `root` logins; use SSH keys and limited sudo where possible.

**Recommended users**

- `ubuntu`: Default cloud image user. Leave as the image default so interactive SSH looks like `ubuntu@kube-master`.
- `deployer` (example): Dedicated automation account with sudo privileges for provisioning (created via cloud-init or the first playbook). This account is used by Ansible for machine configuration.

Security best practices

- Use SSH key authentication only. Disable password authentication and root login in SSH daemon.
- Provision the `deployer` user with an SSH public key and grant `sudo` for required commands (prefer limited sudoers over full NOPASSWD where possible).
- Store secrets (passwords, tokens) in Ansible Vault or a secrets manager — never in plaintext in the repo.
- Rotate keys, log access, and apply least privilege for sudoers entries.

Terraform and `ssh_user`

- The repo currently defines a `ssh_user` Terraform variable. Recommended values:
  - Keep `ssh_user` default set to `ubuntu` so interactive logins use `ubuntu@host`.
  - Add a separate variable `provision_user` (default `deployer`) to convey which user Ansible should use.

Example Terraform variables change (option A — quick):

`````hcl
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}
````markdown
# Provisioning & User Strategy

This document explains recommended user/account strategy and the step-by-step workflow from provisioning infrastructure with Terraform to configuring VMs with Ansible.

**Goals**

- Keep the distro default login user (`ubuntu`) as the VM default SSH account.
- Create a separate dedicated sudo user for automation (e.g., `ansible`) used by Ansible.
- Avoid direct `root` logins; use SSH keys and limited sudo where possible.

**Recommended users**

- `ubuntu`: Default cloud image user. Leave as the image default so interactive SSH looks like `ubuntu@kube-master`.
- `ansible` (example): Dedicated automation account with sudo privileges for provisioning (created via cloud-init or the first playbook). This account is used by Ansible for machine configuration.

Security best practices

- Use SSH key authentication only. Disable password authentication and root login in SSH daemon.
- Provision the `ansible` user with an SSH public key and grant `sudo` for required commands (prefer limited sudoers over full NOPASSWD where possible).
- Store secrets (passwords, tokens) in Ansible Vault or a secrets manager — never in plaintext in the repo.
- Rotate keys, log access, and apply least privilege for sudoers entries.

Terraform and `ssh_user`

- The repo currently defines a `ssh_user` Terraform variable. Recommended values:
  - Keep `ssh_user` default set to `ubuntu` so interactive logins use `ubuntu@host`.
  - Add a separate variable `provision_user` (default `ansible`) to convey which user Ansible should use.

Example Terraform variables change (option A — quick):

```hcl
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "provision_user" {
  type    = string
  default = "ansible"
}
`````

Option B — pass at `terraform apply` time:

```bash
terraform apply -var='ssh_user=ubuntu' -var='provision_user=ansible'
```

How to create the `ansible` user

- Preferred: Create `ansible` via cloud-init in Terraform when creating the VM (add user and `ssh_authorized_keys`).
- Alternative: Use the `01-prepare.yml` Ansible playbook (first playbook) to create the `ansible` user and copy the authorized key from a secure location.

Playbook ordering (run in this order)

- Run these playbooks (inventory and paths are examples from this repo):
  - [ansible/playbooks/01-prepare.yml](ansible/playbooks/01-prepare.yml) — prepare OS, create `ansible` user, install prerequisites
  - [ansible/playbooks/02-k3s-master.yml](ansible/playbooks/02-k3s-master.yml) — configure k3s master
  - [ansible/playbooks/03-k3s-worker.yml](ansible/playbooks/03-k3s-worker.yml) — configure k3s workers
  - [ansible/playbooks/04-jenkins-nexus.yml](ansible/playbooks/04-jenkins-nexus.yml) — CI/CD services
  - [ansible/playbooks/05-monitoring.yml](ansible/playbooks/05-monitoring.yml) — monitoring stack
  - [ansible/playbooks/10-k8s-bootstrap.yml](ansible/playbooks/10-k8s-bootstrap.yml) — cluster bootstrap tasks
  - [ansible/playbooks/99-validate.yml](ansible/playbooks/99-validate.yml) — final validation

Notes on ordering

- `01-prepare.yml` should always run first to ensure the `ansible` user exists and prerequisites (like Python for Ansible, required packages, and correct SSH settings) are in place.
- Keep `99-validate.yml` last to run healthchecks and validations.

Example run sequence (from repo root):

```bash
# 1. Provision infra
cd terraform
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan

# 2. After VMs are up, run Ansible prepare (use the provision user)
cd ..
ansible-playbook -i ansible/inventory.ini ansible/playbooks/01-prepare.yml -u ansible --private-key ~/.ssh/id_rsa

# 3. Continue with the remaining playbooks in order
ansible-playbook -i ansible/inventory.ini ansible/playbooks/02-k3s-master.yml -u ansible --private-key ~/.ssh/id_rsa --become
ansible-playbook -i ansible/inventory.ini ansible/playbooks/03-k3s-worker.yml -u ansible --private-key ~/.ssh/id_rsa --become
ansible-playbook -i ansible/inventory.ini ansible/playbooks/04-jenkins-nexus.yml -u ansible --private-key ~/.ssh/id_rsa --become
ansible-playbook -i ansible/inventory.ini ansible/playbooks/05-monitoring.yml -u ansible --private-key ~/.ssh/id_rsa --become
ansible-playbook -i ansible/inventory.ini ansible/playbooks/10-k8s-bootstrap.yml -u ansible --private-key ~/.ssh/id_rsa --become
ansible-playbook -i ansible/inventory.ini ansible/playbooks/99-validate.yml -u ansible --private-key ~/.ssh/id_rsa --become
```

Running playbooks — common issues & required steps

- Run playbooks from the repository root so Ansible can find `ansible/roles` and your `ansible.cfg`.
- If you run from inside `ansible/` and call `playbooks/01-prepare.yml`, Ansible treats `playbooks` as the playbook directory and looks for roles under `playbooks/roles` (which in this repo does not exist). That causes the error `the role 'user' was not found`.
- Always specify the inventory when running non-default inventory. Example (recommended):

```bash
# from repo root
ansible-playbook -i ansible/inventory.ini ansible/playbooks/01-prepare.yml -u ansible --private-key ~/.ssh/id_rsa --become
```

- The `-u ansible --private-key ~/.ssh/id_rsa --become` flags are convenient for interactive runs when your inventory does not set `ansible_user` or when you prefer explicit override. If your inventory defines `ansible_user` and the generated inventory (from Terraform) contains that value, you can omit `-u` and `--private-key`.

- World-writable directory warning: if you see

  [WARNING]: Ansible is being run in a world writable directory (...), ignoring it as an ansible.cfg source

  fix by running from a non-world-writable directory or remove write permission for `others` on the repo root:

  ```bash
  chmod o-w /path/to/repo
  ```

- If you prefer not to change directory permissions, explicitly point Ansible to a known config file location:

  ```bash
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory.ini ansible/playbooks/01-prepare.yml -u ansible --private-key ~/.ssh/id_rsa --become
  ```

Why the first playbook fails in your case
- You invoked `ansible-playbook playbooks/01-prepare.yml` from inside the `ansible/` directory. Ansible treated `playbooks` as the playbook directory and looked for roles at `playbooks/roles` (not `ansible/roles`), so `import_role: name: user` failed to find the `user` role.

Quick checklist before running playbooks
- Ensure VMs are up and reachable (ping/SSH).
- Make sure your SSH public key is present in the VM (cloud-init or via `01-prepare.yml` when run interactively as `ubuntu`).
- From repo root run:

```bash
cd /mnt/d/k8s/k8s-devops-lab/proxmox
ansible-playbook -i ansible/inventory.ini ansible/playbooks/01-prepare.yml -u ansible --private-key ~/.ssh/id_rsa --become
```

- Continue with the remaining playbooks using the same `-u` and `--private-key` flags or remove them once inventory is correctly populated with `ansible_user`.

Static inventory note
- `ansible/inventory/static.yml` currently contains `ansible_user: terraform` — update it to `ansible` or parameterize it if you plan to use that file. The Terraform-generated `ansible/inventory.ini` already uses the `provision_user` value and will contain `ansible_user=ansible` after provisioning.

Inventory and SSH details

- The repo contains `ansible/inventory.ini` and inventory files under `ansible/inventory/`.
- Ensure your SSH public key is installed into `ubuntu` (if using cloud image default) and/or into `ansible` depending on how you create the user.
- If you create `ansible` via a playbook, you may first SSH in as `ubuntu` to debug, but automation should use `ansible`.

Additional recommendations

- Use a separate SSH keypair for automation (store the private key on the controller only, and public key in VMs).
- Add a `provision_user` variable to the Ansible inventory or `ansible.cfg` as `remote_user` for consistency.
- Consider adding a small bootstrap script or cloud-init template to guarantee the `ansible` user exists immediately after VM creation.

Questions / Next steps

- I can update `terraform/variables.tf` to change `ssh_user` default to `ubuntu` and add `provision_user` (and wire it into terraform modules) if you want — confirm and I will patch it.
- I can also add a minimal cloud-init example for creating the `ansible` user and show how to pass the `ssh_public_key` variable into it.

---

Generated on 2026-01-14

```

```
