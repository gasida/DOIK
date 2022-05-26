#!/bin/bash -xe

echo "[TASK 10] Install Calico CNI"
#kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/calico-crosssubnet-v3.22.2.yaml

echo "sleep 5"
sleep 5

echo "[TASK 11] Setting PS1"
kubectl config rename-context "kubernetes-admin@kubernetes" "DOIK-Lab"

echo "[TASK 12] Install Metrics server - v0.6.1"
kubectl apply -f  https://raw.githubusercontent.com/gasida/DOIK/main/1/metrics-server.yaml

echo "[TASK 13] Dynamically provisioning persistent local storage with Kubernetes - v0.0.22"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "[TASK 14] NFS External Provisioner - v4.0.16"
# https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
kubectl taint node k8s-m node-role.kubernetes.io-
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-provisioner -n kube-system nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.10.10 --set nfs.path=/nfs4-share --set nodeSelector."kubernetes\.io/hostname"=k8s-m
sleep 3
kubectl taint node k8s-m node-role.kubernetes.io=master:NoSchedule
