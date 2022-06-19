#!/bin/bash -x

CONTAINTERD_VER="1.6.4-1"
KUBE_VER="1.24.2"

apt-get update && apt-get install -y \
  ca-certificates curl gnupg lsb-release nftables

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y \
  containerd.io=${CONTAINTERD_VER} \
 
containerd config default > /etc/containerd/config.toml
systemctl restart containerd

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=${KUBE_VER}-00 kubeadm=${KUBE_VER}-00 kubectl=${KUBE_VER}-00
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm config images pull --kubernetes-version=v${KUBE_VER}

swapoff -a
apt-get purge bolt apparmor snap apport bc bcache-tools btrfs-progs dirmngr dosfstools eject htop 
apt autoclean
rm -Rf /var/cache/apt/*
