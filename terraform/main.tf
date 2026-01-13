terraform {
  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.5.0"
    }
  }
}

provider "multipass" {}

# --- Control Plane VM ---
resource "multipass_instance" "control_plane" {
  name   = "k8s-control-plane"
  image  = "noble" # Ubuntu 24.04 LTS
  cpus   = 2
  memory = "2G"
  disk   = "15G" # Increased slightly for 24.04 overhead

  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - curl
      - apt-transport-https
      - ca-certificates
    runcmd:
      - echo "Control Plane (Noble) Initialized" > /tmp/status
  EOT
}

# --- Worker Nodes ---
resource "multipass_instance" "workers" {
  count  = 2
  name   = "k8s-worker-${count.index + 1}"
  image  = "noble" # Ubuntu 24.04 LTS
  cpus   = 2
  memory = "2G"
  disk   = "10G"

  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    runcmd:
      - echo "Worker Node ${count.index + 1} (Noble) Initialized" > /tmp/status
  EOT
}

# --- Outputs ---
output "control_plane_ip" {
  value = multipass_instance.control_plane.ipv4
}

output "worker_ips" {
  value = multipass_instance.workers[*].ipv4
}
