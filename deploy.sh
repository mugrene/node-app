#!/bin/bash

# This script automates the deployment of a K3s Kubernetes cluster using Terraform and Ansible.
# It also deploys a sample Node application to verify the cluster is functioning correctly.

echo "=========== Creating virtual machines using terraform ==========="
cd terraform/
terraform init
terraform validate
terraform apply --auto-approve
multipass list
cd ..

echo "======== Creating the microk8s cluster using ansible ==========="
cd ansible
ansible-playbook -i inventory.yml automate_k3s_provisioning.yaml
cd ..

echo "========= Deployment of our docker images to the microk8s cluster =========="
cd k8s
kubectl apply -f deployment.yaml
kubectl apply -f deploymentservice.yaml
cd ..

kubectl get deployments
kubectl get pods
kubectl get services

kubectl get all --all-namespaces

# Replace <pod-name> with the name from the previous step
# kubectl exec -it nginx-66686b6766-dxgmb -- /bin/bash
# curl http://localhost:3000
