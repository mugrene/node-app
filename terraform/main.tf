terraform {
  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.5.0"
    }
  }
}

provider "multipass" {}

# --- Variables ---
# This reads your existing public key from the default location.
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub" 
}

# --- Control Plane VM ---
resource "multipass_instance" "control_plane" {
  name   = "k8s-control-plane"
  image  = "noble" # Ubuntu 24.04
  cpus   = 2
  memory = "2G"
  disk   = "15G"

  cloud_init = <<-EOT
    #cloud-config
    users:
      - default
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${file(var.ssh_public_key_path)}
    package_update: true
    packages:
      - curl
    runcmd:
      - echo "Control Plane with SSH ready" > /tmp/status
  EOT
}

# --- Worker Nodes ---
resource "multipass_instance" "workers" {
  count  = 2
  name   = "k8s-worker-${count.index + 1}"
  image  = "noble"
  cpus   = 2
  memory = "2G"
  disk   = "10G"

  cloud_init = <<-EOT
    #cloud-config
    users:
      - default
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${file(var.ssh_public_key_path)}
    package_update: true
    runcmd:
      - echo "Worker ${count.index + 1} with SSH ready" > /tmp/status
  EOT
}

# --- Outputs ---
output "control_plane_ip" {
  value = multipass_instance.control_plane.ipv4
}

output "worker_ips" {
  value = multipass_instance.workers[*].ipv4
}
