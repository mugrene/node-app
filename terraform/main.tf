terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4.2"
    }
  }
}

provider "multipass" {}

# Provision the Master Virtual Machine
resource "multipass_instance" "k3s_master" {
  name   = "k3s-master"
  image  = "noble" # Ubuntu 24.04 LTS 
  cpus   = 2
  memory = "2GiB"
  disk   = "10GiB"
}

# Provision the Worker Virtual Machines
resource "multipass_instance" "k3s_worker" {
  count  = 3 
  name   = "k3s-worker-${count.index + 1}" 
  image  = "noble" 
  cpus   = 1
  memory = "2GiB"
  disk   = "10GiB"
} # <--- This was the missing bracket

# Output IPs so Ansible can reach them via SSH
output "master_ip" {
  value = multipass_instance.k3s_master.ipv4 
}

output "worker_ips" {
  # Use the splat operator [*] to get IPs for all 3 workers
  value = multipass_instance.k3s_worker[*].ipv4 
}