variable "worker1_name" {
  default = "WORKER1-vm1"
}

variable "worker1_ip" {
  default = "10.188.55.130"
}

variable "worker2_name" {
  default = "WORKER2-vm2"
}

variable "worker2_ip" {
  default = "10.188.55.18"
}

resource "null_resource" "create_worker1" {
  provisioner "local-exec" {
    command = "multipass launch 24.04 --name ${var.worker1_name} --cpus 2 --mem 2G --disk 10G --cloud-init /home/d-code/Documents/mugrene/terraform/cloud-init-worker1.yaml"
  }
}

resource "null_resource" "create_worker2" {
  provisioner "local-exec" {
    command = "multipass launch 24.04 --name ${var.worker2_name} --cpus 2 --mem 2G --disk 10G --cloud-init /home/d-code/Documents/mugrene/terraform/cloud-init-worker2.yaml"
  }
}

output "worker1_name" {
  value = var.worker1_name
}

output "worker2_name" {
  value = var.worker2_name
}
