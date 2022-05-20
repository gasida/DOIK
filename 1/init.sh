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
apt update && apt install -y tree jq sshpass bridge-utils net-tools bat exa
echo 'alias cat=batcat --paging=never' >> /etc/profile

echo "[TASK 6] Setting Local DNS Using Hosts file"
#for (( i=1; i<=$1; i++  )); do echo "192.168.10.10$i k8s-w$i" >> /etc/hosts; done
echo "192.168.10.10 k8s-m" >> /etc/hosts
echo "192.168.10.101 k8s-w1" >> /etc/hosts
echo "192.168.10.102 k8s-w2" >> /etc/hosts
echo "192.168.20.103 k8s-w3" >> /etc/hosts
echo "192.168.20.104 k8s-w4" >> /etc/hosts

echo "[TASK 7] Install Docker Engine"
curl -fsSL https://get.docker.com | sh

echo "[TASK 8] Change Cgroup Driver Using Systemd"
cat <<EOT > /etc/docker/daemon.json
{"exec-opts": ["native.cgroupdriver=systemd"]}
EOT
systemctl daemon-reload && systemctl restart docker

echo "[TASK 9] Install Kubernetes components (kubeadm, kubelet and kubectl)"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y kubelet=1.23.6-00 kubectl=1.23.6-00 kubeadm=1.23.6-00
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

echo "[TASK 10] Git Clone"
git clone https://github.com/gasida/DOIK.git /root/DOIK
find /root/DOIK -regex ".*\.\(sh\)" -exec chmod 700 {} \;

echo ">>>> Initial Config End <<<<"
