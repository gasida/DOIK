#!/bin/bash -xe
echo ">>>> K8S Final config Start <<<<"

echo "[TASK 9] Install Flannel CNI"
#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/kube-flannel-v0.18.0.yml

echo "sleep 3"
sleep 3

echo "[TASK 10] Setting PS1"
kubectl config rename-context "kubernetes-admin@kubernetes" "DOIK-Lab"

echo "[TASK 11] Install Metrics server on k8s-m node - v0.6.1"
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/metrics-server.yaml

echo "[TASK 12] Dynamically provisioning persistent local storage with Kubernetes on k8s-m node - v0.0.22"
kubectl apply -f https://raw.githubusercontent.com/gasida/DOIK/main/1/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "[TASK 13] NFS External Provisioner on AWS EFS - v4.0.16"
# https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
printf 'tolerations: [{key: node-role.kubernetes.io/master, operator: Exists, effect: NoSchedule}]\n' | \
  helm install nfs-provisioner -n kube-system nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=$(cat /root/efs.txt) --set nfs.path=/ --set nodeSelector."kubernetes\.io/hostname"=k8s-m \
  --values /dev/stdin

echo "[TASK 14] K8S v1.24 : k8s-m node config taint & label"
kubectl taint node k8s-m node-role.kubernetes.io/control-plane- >/dev/null 2>&1
kubectl label nodes k8s-m node-role.kubernetes.io/master= >/dev/null 2>&1

echo ">>>> K8S Final Config End <<<<"
