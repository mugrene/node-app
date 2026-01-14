# Automate K3s Cluster Setup on Multipass using Terraform and Ansible (Ubuntu 24.04)

This Ansible playbook automates the creation of a lightweight K3s Kubernetes cluster on Multipass using your Ubuntu 24.04.
It provisions one master node and three worker nodes, installs K3s, and configures your local kubeconfig automatically.

Tear down and recreate the cluster anytime by simply rerunning the playbook

| Node Name       | vCPU | RAM | Disk  | Role   |
| --------------- | ---- | --- | ----  | ------ |
| `k3s-master`    | 2    | 2GB | 20GB  | Master |
| `k3s-worker-1`  | 1    | 1GB | 10GB  | Worker |
| `k3s-worker-2`  | 1    | 1GB | 10GB  | Worker |
| `k3s-worker-3`  | 1    | 1GB | 10GB  | Worker |


### Prerequisites

### Clone the repository

```bash
git clone https://github.com/mugrene/node-app.git
cd node-app
```
### Run install prequiste

```bash
chmod +x setup.sh
```

```bash
./setup.sh
```

### Run the deployment script

```bash
chmod +x deploy.sh
./deploy.sh
```
### Update configuration (optional)

If you want to modify node specs, names, or counts, update the variables in your playbooks or inventory file.


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

> That is it. Enjoy!





