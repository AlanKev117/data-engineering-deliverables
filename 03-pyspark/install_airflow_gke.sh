#!/bin/zsh

# Terraform directory
TERRAFORM_DIR=../01-terraform/gcp/

# Set your env file with the connection variables data
SQL_CONN_ENV_FILE=connection.env

# Path to your service account JSON file
GCP_KEY_FILE=gcp-key.json

# Save worrking directory and swap it to terraform's
CURRENT_DIR=$(pwd)
cd $TERRAFORM_DIR

# ==== Expressions that involve use of terraform ====

# Get GKE credentials for kubectl
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw location)

# Load secrets env vars
source ${CURRENT_DIR}/${SQL_CONN_ENV_FILE}

# Restore working directory
cd $CURRENT_DIR

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

# Install secrets

# SA key file secret
kubectl create secret generic gcp-key \
    --from-file=gcp-key.json=${GCP_KEY_FILE} \
    --namespace airflow

# GCP secrets
kubectl create secret generic gcp \
    --from-literal=project-id=${GCP_PROJECT_ID} \
    --from-literal=uri=${GCP_CONNECTION_URI}
    --namespace airflow

# SQL secrets
kubectl create secret generic gcp-sql \
    --from-literal=schema=${SQL_SCHEMA} \
    --from-literal=table=${SQL_TABLE} \
    --from-literal=uri=${SQL_CONNECTION_URI} \
    --namespace airflow

# Dataproc secrets
kubectl create secret generic gcp-dataproc \
    --from-literal=cluster=${DATAPROC_CLUSTER}
    --from-literal=job-uri=${DATAPROC_JOB_URI}
    --from-literal=region=${DATAPROC_REGION}
    --namespace airflow

kubectl create secret generic gcp-storage \
    --from-literal=raw=${STORAGE_RAW_BUCKET}
    --from-literal=staging=${STORAGE_STAGING_BUCKET}
    --namespace airflow

# Erase vars once they are stored as secrets
