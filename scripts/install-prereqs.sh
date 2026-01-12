#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "Updating apt and installing prerequisites..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common apt-transport-https

install_if_missing() {
  local cmd=$1
  shift
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Installing $cmd..."
    "$@"
  else
    echo "$cmd already installed"
  fi
}

install_snapd() {
  if ! command -v snap >/dev/null 2>&1; then
    echo "Installing snapd..."
    ${SUDO} apt-get install -y snapd
    ${SUDO} systemctl enable --now snapd.socket || true
  else
    echo "snapd present"
  fi
}

install_multipass() {
  if ! command -v multipass >/dev/null 2>&1; then
    echo "Installing Multipass via snap..."
    ${SUDO} snap install multipass --classic
  else
    echo "Multipass already installed"
  fi
}

install_terraform() {
  if ! command -v terraform >/dev/null 2>&1; then
    echo "Installing Terraform via HashiCorp apt repo..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | ${SUDO} gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | ${SUDO} tee /etc/apt/sources.list.d/hashicorp.list
    ${SUDO} apt-get update -y
    ${SUDO} apt-get install -y terraform || echo "apt terraform install failed; please install manually from https://www.terraform.io/downloads"
  else
    echo "Terraform already installed"
  fi
}

install_ansible() {
  if ! command -v ansible >/dev/null 2>&1; then
    echo "Installing Ansible..."
    ${SUDO} apt-get update -y
    ${SUDO} apt-get install -y ansible
  else
    echo "Ansible already installed"
  fi
}

install_microk8s() {
  if ! snap list microk8s >/dev/null 2>&1; then
    echo "Installing MicroK8s via snap..."
    ${SUDO} snap install microk8s --classic
    ${SUDO} usermod -a -G microk8s ${SUDO:--}${USER}
    ${SUDO} chown -f -R ${USER}:${USER} /home/${USER} || true
    echo "Adding alias: kubectl -> microk8s kubectl (optional)"
  else
    echo "microk8s already installed"
  fi
}

install_kubectl() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl from Kubernetes apt repo..."
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | ${SUDO} tee /etc/apt/sources.list.d/kubernetes.list
    ${SUDO} apt-get update -y
    ${SUDO} apt-get install -y kubectl || echo "kubectl apt install failed; you can install from https://kubernetes.io/docs/tasks/tools/"
  else
    echo "kubectl already installed"
  fi
}

echo "Starting installation steps..."
install_snapd
install_multipass
install_terraform
install_ansible
install_microk8s
install_kubectl

echo
echo "Done. Important next steps:"
echo "- Log out and log back in (or run 'newgrp microk8s') to apply group changes for microk8s." 
echo "- You can use 'microk8s status --wait-ready' to wait until MicroK8s is ready." 
echo "- For cluster admin kubectl you can use 'microk8s kubectl' or configure kubeconfig with 'microk8s config'"
echo
echo "To run this script (make executable first):"
echo "  chmod +x scripts/install-prereqs.sh"
echo "  sudo ./scripts/install-prereqs.sh"
