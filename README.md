# Automate K3s Cluster Setup on Multipass using Ansible (MacBook)

This Ansible playbook automates the creation of a lightweight K3s Kubernetes cluster on Multipass using your MacBook.
It provisions one master node and three worker nodes, installs K3s, and configures your local kubeconfig automatically.

This setup is perfect if you want to:

Practice Kubernetes use cases or few certification labs (CKA, CKAD, CKS)

Quickly spin up a fresh K3s environment for testing

Tear down and recreate the cluster anytime by simply rerunning the playbook

| Node Name       | vCPU | RAM | Disk | Role   |
| --------------- | ---- | --- | ---- | ------ |
| `k3s-master`    | 2    | 4GB | 20GB | Master |
| `k3s-worker-01` | 1    | 1GB | 4GB  | Worker |
| `k3s-worker-02` | 1    | 1GB | 4GB  | Worker |
| `k3s-worker-03` | 1    | 1GB | 4GB  | Worker |


### Prerequisites

Before you begin, make sure you have the following installed on your MacBook:

```bash
brew install --cask multipass
```

```bash
brew install ansible
```

```bash
brew install kubectl
```

### Clone the repository

```bash
git clone https://github.com/gerardpontino/k3s-clustersetup-automation-macbook.git
cd k3s-clustersetup-automation-macbook/
```
### Update configuration (optional)

If you want to modify node specs, names, or counts, update the variables in your playbooks or inventory file.

### Run the Ansible playbook

```bash
ansible-playbook -i inventory.yml automate_k3s_provisioning.yaml
```

This playbook performs the following steps automatically:

- Deletes any existing k3s-master or k3s-worker-* instances (for a clean start)

- Creates one master and three worker nodes on Multipass

- Installs K3s on the master and joins worker nodes to the cluster

- Retrieves and updates your local kubeconfig file (~/.kube/config)

- Displays your K3s cluster node information

You can rerun this playbook anytime to delete and rebuild your cluster — perfect for a fresh lab environment or repeated practice runs.

### Validate the Setup

After the playbook completes, you can validate that all your VMs are running in Multipass:

```bash
multipass list
```

Example output:
```bash
─❯ multipass list
Name                    State             IPv4             Image
k3s-master              Running           192.168.64.94    Ubuntu 24.04 LTS
                                          10.42.0.0
                                          10.42.0.1
k3s-worker-1            Running           192.168.64.95    Ubuntu 24.04 LTS
                                          10.42.1.0
k3s-worker-2            Running           192.168.64.96    Ubuntu 24.04 LTS
                                          10.42.2.0
k3s-worker-3            Running           192.168.64.97    Ubuntu 24.04 LTS
                                          10.42.3.0
```

You should see all instances in a Running state.
Below is an example screenshot of the Multipass instances list:

<img width="1396" height="559" alt="Screenshot 2025-10-21 at 10 23 31 PM" src="https://github.com/user-attachments/assets/96aeab2b-6e45-499e-8ded-6149550bc775" />

### Accessing the Cluster

After the setup finishes, you can check your cluster status using:

```bash
kubectl get nodes
```

```bash
NAME           STATUS   ROLES                  AGE   VERSION
k3s-master     Ready    control-plane,master   18m   v1.33.5+k3s1
k3s-worker-1   Ready    <none>                 18m   v1.33.5+k3s1
k3s-worker-2   Ready    <none>                 18m   v1.33.5+k3s1
k3s-worker-3   Ready    <none>                 17m   v1.33.5+k3s1
```

>Easily recreate a clean, ready-to-use K3s lab anytime — perfect for testing, learning, and automation practice. Enjoy!





