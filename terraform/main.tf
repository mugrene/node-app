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
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "multipass" {}

# --- 1. Generate a New SSH Key Pair ---
# This ensures you never get a "missing private key" error.
resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- 2. Define the Cloud-Init Config ---
locals {
  user_data = <<-EOT
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
      - git
      - apt-transport-https
  EOT
}

# --- 3. Control Plane VM ---
resource "multipass_instance" "control_plane" {
  name       = "k8s-control-plane"
  image      = "noble" # Ubuntu 24.04
  cpus       = 2
  memory     = "2GiB"
  disk       = "15GiB"
  cloudinit  = local.user_data
}

# --- 4. Worker Nodes ---
resource "multipass_instance" "workers" {
  count      = 2
  name       = "k8s-worker-${count.index + 1}"
  image      = "noble"
  cpus       = 2
  memory     = "2GiB"
  disk       = "10GiB"
  cloudinit  = local.user_data
}

# --- 5. Save the Private Key locally ---
# This creates the file you'll use to SSH into the VMs.
resource "local_sensitive_file" "ssh_key" {
  content         = tls_private_key.vm_key.private_key_pem
  filename        = "${path.module}/id_rsa_multipass"
  file_permission = "0600"
}

# --- 6. Outputs ---
output "control_plane_ip" {
  value = multipass_instance.control_plane.ipv4
}

output "worker_ips" {
  value = multipass_instance.workers[*].ipv4
}
