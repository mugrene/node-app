terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "1.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "multipass" {}

# --- 1. Generate SSH Key Pair ---
# This solves the "missing private key" issue by creating one on the fly.
resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- 2. Define Cloud-Init Content ---
locals {
  cloud_init_config = <<-EOT
    #cloud-config
    users:
      - default
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${tls_private_key.vm_key.public_key_openssh}
    package_update: true
    packages:
      - curl
  EOT
}

# --- 3. Control Plane VM ---
resource "multipass_instance" "control_plane" {
  name      = "k8s-control-plane"
  image     = "noble" # Ubuntu 24.04
  cpus      = 2
  memory    = "2GiB"
  disk      = "15GiB"
  cloudinit = local.cloud_init_config # Correct attribute name for v1.4.3
}

# --- 4. Worker Nodes ---
resource "multipass_instance" "workers" {
  count     = 2
  name      = "k8s-worker-${count.index + 1}"
  image     = "noble"
  cpus      = 2
  memory    = "2GiB"
  disk      = "10GiB"
  cloudinit = local.cloud_init_config
}

# --- 5. Outputs ---
output "control_plane_ip" {
  value = multipass_instance.control_plane.ipv4
}

output "worker_ips" {
  value = multipass_instance.workers[*].ipv4
}

# Save the generated private key to a file so you can use it to SSH
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.vm_key.private_key_pem
  filename        = "${path.module}/id_rsa_multipass"
  file_permission = "0600"
}
