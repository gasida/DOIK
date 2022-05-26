#!/bin/bash -xe

echo "[TASK 10] Install Calico CNI on k8s-m node"
#kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/calico-crosssubnet-v3.22.2.yaml

echo "sleep 3"
sleep 3

echo "[TASK 11] Setting PS1"
kubectl config rename-context "kubernetes-admin@kubernetes" "DOIK-Lab"

echo "[TASK 12] Install Metrics server on k8s-m node - v0.6.1"
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/metrics-server.yaml

echo "[TASK 13] Dynamically provisioning persistent local storage with Kubernetes on k8s-m node - v0.0.22"
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "[TASK 14] NFS External Provisioner on k8s-m node - v4.0.16"
# https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
#helm install nfs-provisioner -n kube-system nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.10.10 --set nfs.path=/nfs4-share --set nodeSelector."kubernetes\.io/hostname"=k8s-m
printf 'tolerations: [{key: node-role.kubernetes.io/master, operator: Exists, effect: NoSchedule}]\n' | \
  helm install nfs-provisioner -n kube-system nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=192.168.10.10 --set nfs.path=/nfs4-share --set nodeSelector."kubernetes\.io/hostname"=k8s-m \
  --values /dev/stdin