# Multipass + MicroK8s (Terraform + Ansible) — quick guide

This workspace provides a simple Terraform + Ansible setup to create two Multipass worker VMs and deploy the Docker image `mugrene/node-app` to a MicroK8s control plane at IP `10.188.55.1`.

Files added:
- `terraform/main.tf` — launches two Multipass VMs using `multipass launch` (via `local-exec`).
- `terraform/cloud-init-worker1.yaml` and `cloud-init-worker2.yaml` — simple cloud-init to install `microk8s` snap.
- `ansible/inventory.ini` — inventory listing control and worker IPs.
- `ansible/playbook.yml` — playbook that retrieves the `microk8s` join command from the control plane, runs it on workers, and deploys `mugrene/node-app`.

Prerequisites
- `multipass` installed and configured on the host.
- `terraform` installed.
- `ansible` installed.
- Ensure the control plane (MicroK8s) is already running on 10.188.55.1.

Notes about networking and IPs
- Multipass instances by default use NAT; assigning static, host-reachable IPs typically requires host-side bridged networking or additional network setup. The cloud-init files included install microk8s inside the VMs but do not force a host-visible static address.

Quick run

1. Create the worker VMs (this runs `multipass launch`):

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

2. Confirm the VMs exist with `multipass list` and ensure SSH connectivity / IP reachability.

3. Run the Ansible playbook to join workers and deploy the app:

```bash
cd /opt/node-app
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -u ubuntu --private-key /path/to/your/ssh_key
```

If you use Multipass-managed SSH keys, you can extract the SSH key or use `multipass exec` to run commands inside the instances.

If you want me to adapt this to a real Terraform Multipass provider (instead of `local-exec`) or make the playbook install microk8s via Ansible rather than cloud-init, tell me which option you prefer and I will update the files.
