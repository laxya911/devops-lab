# Upgrade & Automation Plan — k8s-devops-lab

This document contains an actionable plan to reduce manual work, align Terraform/Ansible, and improve reliability for the Proxmox + k3s + Jenkins/Nexus lab.

Summary of immediate goals

- Align cloud-init user between Terraform and Ansible so playbooks don't assume different usernames.
- Bootstrap VMs with cloud-init (create `ansible` user, inject SSH key, install qemu-agent and minimal packages).
- Output real instance IP addresses from Terraform and automatically generate `ansible/inventory.ini` after `terraform apply`.
- Do not install Docker on k3s nodes (k3s uses `containerd`). Manage containerd registry config instead.
- Run Jenkins & Nexus as containers on the CI VM (recommended) to simplify upgrades and isolation; ensure persistent volume for `JENKINS_HOME` and Nexus data.
- Centralize secrets (Ansible Vault or external vault) and push credentials from Jenkins pipeline securely.

Concrete steps

1. Terraform changes

- Make cloud-init user configurable and set to the Ansible user used by playbooks (e.g. `ansible` or `ubuntu`). Replace hard-coded `ciuser` with `var.ssh_user` in `terraform/instances.tf`.
- Add `ssh_password` variable (if you must set a password) and keep SSH key primary method.
- Replace variable-only IP outputs with instance attributes (if available) such as `proxmox_vm_qemu.<name>.default_ipv4_address` and expose them via `terraform output`.
- Add a `null_resource`/`local-exec` provisioner that writes `ansible/inventory.ini` from the real IPs after apply. This eliminates manual inventory edits.

2. Cloud-init / bootstrap

- Use `sshkeys` and `ciuser` (cloud-init) to ensure an `ansible` user exists with sudo and the public key already in `~/.ssh/authorized_keys`.
- Preinstall `qemu-guest-agent` and minimal packages (curl, python3) so Ansible can run immediately.
- Example cloud-init snippet (template or `user_data`):

```yaml
#cloud-config
users:
  - name: ansible
    gecos: Ansible User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - { { ssh_public_key } }
packages:
  - qemu-guest-agent
  - python3
runcmd:
  - systemctl enable --now qemu-guest-agent
```

3. Ansible changes

- Parameterize playbooks to use an `ansible_user` variable (replace instances of `/home/ubuntu` with `/home/{{ ansible_user }}`).
- Add a small role `roles/user` to create the `ansible` user, ensure `~/.ssh/authorized_keys`, and configure sudoers.
- Avoid installing Docker on k3s nodes. Instead, add `roles/containerd` to manage `/etc/rancher/k3s/registries.yaml` or `containerd` config to add insecure registries/mirrors.
- Add `roles/docker` used only on the CI host(s) to template `/etc/docker/daemon.json` and restart docker using handlers.

containerd registry example for k3s (place on master and distribute to workers as needed):

```yaml
mirrors:
  'my-registry:5000':
    endpoint:
      - 'http://my-registry:5000'
configs:
  'my-registry:5000':
    tls:
      insecure_skip_verify: true
```

4. Jenkins & Nexus deployment options

- Recommended: Run both Jenkins and Nexus as containers on the CI VM using Docker (or Podman) with persistent volumes. This simplifies upgrades and isolates Java processes.
- For Docker image builds from Jenkins pipelines, avoid running Docker on k3s nodes. Options:
  - Mount host Docker socket into Jenkins container (fast but insecure): mount `/var/run/docker.sock` and install Docker CLI in container.
  - Use DinD (Docker-in-Docker) with privileged container (less recommended for security).
  - Prefer Kaniko / BuildKit / Buildx to build images in containers without requiring host Docker socket.

Minimal `docker run` example to start Jenkins container (bind-mount for JENKINS_HOME):

```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /opt/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \ # optional; insecure but enables builds
  jenkins/jenkins:lts
```

For Nexus (docker):

```bash
docker run -d --name nexus -p 8081:8081 -v /opt/nexus/data:/nexus-data sonatype/nexus3:latest
```

Notes on resource usage: running Jenkins in a container does not magically reduce Java heap requirements, but it simplifies scaling, isolation, and lifecycle management. Tune Jenkins JVM heap (`-Xmx`) and the container resource limits. If memory pressure persists, consider:

- increasing VM RAM further,
- moving build-intensive workloads into ephemeral build agents (Kubernetes agents), or
- offloading heavy tasks (image builds) to Kaniko/GitHub Actions/remote builders.

5. CI pipeline orchestration (Jenkins)

- Flow: generate or reuse an SSH keypair → pass public key to Terraform (`-var='ssh_public_key=...'`) → `terraform apply` → Terraform generates `ansible/inventory.ini` → Jenkins uses private key credential to run `ansible-playbook` against inventory.
- Example pipeline steps (shell snippets):

```bash
# terraform
terraform init
terraform apply -auto-approve -var="ssh_public_key=${PUBLIC_KEY}"

# run Ansible using Jenkins stored private key
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory.ini ansible/playbooks/01-prepare.yml --private-key /path/to/private_key
ansible-playbook -i ansible/inventory.ini ansible/playbooks/02-k3s-master.yml --private-key /path/to/private_key
```

6. Secrets

- Use Jenkins credentials store for SSH private key, Nexus admin password, and registry credentials.
- Use Ansible Vault or an external secret manager to store long-lived secrets used by playbooks.

7. Health checks and validation

- Add a small `ansible/playbooks/99-validate.yml` that verifies:
  - `ansible` user exists and SSH works,
  - k3s control plane responding and nodes Ready,
  - Docker running on CI host, and Jenkins/Nexus endpoints healthy,
  - registry reachable/credentials valid.

8. First-run UI passwords

- When Jenkins and Nexus are first created they have initial admin passwords. Automate retrieval and store into Jenkins credentials (or Vault) on first successful run, but rotate them immediately for security.

Optional / long-term

- Use internal CA and issue TLS certs for registry and k3s API to avoid 'insecure' registry settings.
- Consider running Jenkins agents in Kubernetes (k3s) to scale builds and reduce resource usage on the CI VM.

