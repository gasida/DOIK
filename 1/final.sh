#!/bin/bash -xe

echo "[TASK 10] Install Calico CNI"
#kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/gasida/book-k8s-network/main/5/calico-v3.22.2.yaml

echo "sleep 1m"
sleep 1m

echo "[TASK 11] Setting PS1"
kubectl config rename-context "kubernetes-admin@kubernetes" "DOIK-Lab"

echo "[TASK 12] Install Metrics server - v0.6.1"
kubectl apply -f https://raw.githubusercontent.com/gasida/KANS/main/8/metrics-server.yaml

echo "[TASK 13] Dynamically provisioning persistent local storage with Kubernetes - v0.0.22"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'