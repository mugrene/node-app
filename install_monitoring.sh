#!/bin/bash

# Install of prometheus

# Update and install
sudo apt update
sudo apt install prometheus prometheus-node-exporter -y

# Enable and start the services
sudo systemctl enable --now prometheus
sudo systemctl enable --now prometheus-node-exporter

# Install Grafana
# Install dependencies
sudo apt-get install -y apt-transport-https software-properties-common wget

# Add the GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add the repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Install Grafana
sudo apt-get update
sudo apt-get install grafana -y

# Start and enable the service
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server
