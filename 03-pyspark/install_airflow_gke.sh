#!/bin/zsh

# Get cluster endpoint to kubectl (connection)
# gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw location)
# gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region us-central1-a

# Create nfs server
kubectl create namespace nfs
kubectl -n nfs apply -f nfs-server.yaml
export NFS_SERVER=$(kubectl -n nfs get service/nfs-server -o jsonpath="{.spec.clusterIP}") 

# Enable nfs server for cluster
kubectl create namespace storage
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace storage \
    --set nfs.server=$NFS_SERVER \
    --set nfs.path=/

# Deploy airflow
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow -n airflow -f values.yaml

# kubectl get pods -n airflow
# kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
# helm delete airflow --namespace airflow
# kubectl create secret generic gcp-key --from-file=key.json=csa-key.json

# Install secrets
kubectl create secret generic gcp-key \
    --from-file=gcp-key.json=gcp-key.json \
    --namespace airflow

