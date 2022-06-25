#!/bin/bash -xe
echo ">>>> Initial Config Start <<<<"
echo "[TASK 1] Setting Root Password"
printf "Pa55W0rd\nPa55W0rd\n" | passwd

echo "[TASK 2] Setting Sshd Config"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
systemctl restart sshd
echo  > .ssh/authorized_keys

echo "[TASK 3] Change Timezone & Setting Profile & Bashrc"
# Change Timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
#  Setting Profile & Bashrc
echo 'alias vi=vim' >> /etc/profile
echo "sudo su -" >> /home/ubuntu/.bashrc

echo "[TASK 4] Disable ufw & AppArmor"
systemctl stop ufw && systemctl disable ufw
systemctl stop apparmor && systemctl disable apparmor

echo "[TASK 5] Install Packages"
apt update && apt install -y tree jq sshpass bridge-utils net-tools bat exa duf nfs-common sysstat
echo "alias cat='batcat --paging=never'" >> /etc/profile

echo "[TASK 6] Setting Local DNS Using Hosts file"
echo "192.168.10.10 k8s-m" >> /etc/hosts
echo "192.168.10.101 k8s-w1" >> /etc/hosts
echo "192.168.10.102 k8s-w2" >> /etc/hosts
echo "192.168.20.103 k8s-w3" >> /etc/hosts
#echo "192.168.20.104 k8s-w4" >> /etc/hosts

echo "[TASK 7] Install containerd.io"
# Install Runtime - Containerd https://kubernetes.io/docs/setup/production-environment/container-runtimes/
cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p 
sysctl --system 

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update 
apt-get install containerd.io -y
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

echo "[TASK 8] Using the systemd cgroup driver"
#sed -i'' -r -e "/runc.options/a\            SystemdCgroup = true" /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd

# Change container runtime args
cat <<EOF > /etc/default/kubelet
KUBELET_KUBEADM_ARGS=--container-runtime=remote --container-runtime-endpoint=/run/containerd/containerd.sock --cgroup-driver=systemd
EOF

# Change runtime endpoint
cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF

echo "[TASK 9] Install Kubernetes components (kubeadm, kubelet and kubectl)"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y kubelet=$KUBERNETES_VERSION-00 kubectl=$KUBERNETES_VERSION-00 kubeadm=$KUBERNETES_VERSION-00
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

echo "[TASK 10] Git Clone"
git clone https://github.com/gasida/DOIK.git /root/DOIK
find /root/DOIK -regex ".*\.\(sh\)" -exec chmod 700 {} \;
cp /root/DOIK/1/final2.sh /root/final.sh

echo ">>>> Initial Config End <<<<"
