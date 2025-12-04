#!/bin/bash
set -e

# 1. Block interactive pop-ups (very important for automation)
export DEBIAN_FRONTEND=noninteractive

# 2. Update and basic tools
# Fix: Clean apt lists to avoid hash mismatch errors
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get clean

# Robust update with retry
for i in 1 2 3; do
    sudo apt-get update && break || echo "Apt update failed, retrying..." && sleep 5
done
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 3. Docker Installation (Official)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 4. Nvidia Drivers & Toolkit Installation
# Note: Let Ubuntu detect the best driver via ubuntu-drivers
sudo apt-get install -y ubuntu-drivers-common
sudo ubuntu-drivers autoinstall
#BRUTEFORCE just in case
sudo apt-get install -y nvidia-driver-535 nvidia-utils-535

# 5. Nvidia Container Toolkit (So Docker can see the GPU)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# 6. Cleanup to reduce image size
sudo apt-get clean
rm -rf /var/lib/apt/lists/*