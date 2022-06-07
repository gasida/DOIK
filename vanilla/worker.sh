#!/bin/bash -xe

echo ">>>> K8S Node config Start <<<<"

echo "[TASK 1] K8S Controlplane Join - API Server 192.168.10.10" 
kubeadm join --token 123456.1234567890123456 --discovery-token-unsafe-skip-ca-verification 192.168.10.10:6443

echo "[TASK 2] Config kubeconfig" 
mkdir -p /root/.kube
sshpass -p "Pa55W0rd" scp -o StrictHostKeyChecking=no root@k8s-m:/etc/kubernetes/admin.conf /root/.kube/config

echo "[TASK 3] Source the completion"
echo 'source <(kubectl completion bash)' >> /etc/profile

echo "[TASK 4] Alias kubectl to k"
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

echo "[TASK 5] Install Helm"
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo ">>>> K8S Node config End <<<<"
