#!/bin/bash -xe
echo ">>>> K8S Controlplane config Start <<<<"

echo "[TASK 1] Initial Kubernetes - Pod CIDR 172.16.0.0/16 , Service CIDR 10.200.1.0/24 , API Server 192.168.10.10"
kubeadm init --token 123456.1234567890123456 --token-ttl 0 --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.10.10 --service-cidr 10.200.1.0/24 

echo "[TASK 2] Setting kube config file"
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

echo "[TASK 3] Source the completion"
echo 'source <(kubectl completion bash)' >> /etc/profile

echo "[TASK 4] Alias kubectl to k"
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

echo "[TASK 5] Install Kubectx & Kubens"
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

echo "[TASK 6] Install Kubeps"
git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1
cat <<"EOT" >> /root/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=true
KUBE_PS1_SYMBOL_DEFAULT=🐱
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT

echo "[TASK 7] Install Packages"
apt install kubetail etcd-client -y

echo "[TASK 8] Install Helm"
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo "[TASK 9] Create Directory"
mkdir /nfs4-share

# echo "[TASK 9] Config NFS Server"
# apt install -y nfs-kernel-server
# mkdir /nfs4-share
# echo '/nfs4-share *(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports
# systemctl enable nfs-server
# exportfs -r && exportfs -v

echo ">>>> K8S Controlplane Config End <<<<"
