#!/bin/zsh

# Terraform directory
TERRAFORM_DIR=../01-terraform/gcp/

# Set your env file with the connection variables data
SQL_CONN_ENV_FILE=connection.env

# Set your service account JSON file
GCP_KEY_FILE=gcp-key.json

# Save call directory
CURRENT_DIR=$(pwd)
cd $TERRAFORM_DIR

# ==== Expressions that involve use of terraform ====

# Get GKE credentials for kubectl
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw location)

# Load secrets
source ${CURRENT_DIR}/${SQL_CONN_ENV_FILE}

# Restore call directory
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

kubectl create secret generic gcp-key \
    --from-file=gcp-key.json=${GCP_KEY_FILE} \
    --namespace airflow

kubectl create secret generic gcp-sql \
    --from-literal=host=${CLOUD_SQL_HOST} \
    --from-literal=login=${CLOUD_SQL_LOGIN} \
    --from-literal=pw=${CLOUD_SQL_PW} \
    --from-literal=port=${CLOUD_SQL_PORT} \
    --from-literal=schema=${CLOUD_SQL_DB} \
    --from-literal=type=${CLOUD_SQL_LOCATION} \
    --from-literal=instance=${CLOUD_SQL_INSTANCE} \
    --from-literal=type=${CLOUD_SQL_TYPE} \
    --from-literal=uri=${AIRFLOW_URI} \
    --namespace airflow

# Ease vars once they are stored as secrets
unset CLOUD_SQL_HOST
unset CLOUD_SQL_LOGIN
unset CLOUD_SQL_PW
unset CLOUD_SQL_PORT
unset CLOUD_SQL_DB
unset CLOUD_SQL_LOCATION
unset CLOUD_SQL_INSTANCE
unset CLOUD_SQL_TYPE
unset AIRFLOW_URI