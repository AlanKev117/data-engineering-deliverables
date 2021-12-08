#!/bin/zsh

# Save current worrking directory
CALL_DIR=$(pwd)

# Terraform directory
TERRAFORM_DIR=../01-terraform

# file with env variables for airflow cluster (relative to current working directory)
SQL_CONN_ENV_FILE=connection.env

# Path to your service account JSON file (relative to current working directory)
GCP_KEY_FILE=gcp-key.json


# ==== Expressions that involve use of terraform ====

cd $TERRAFORM_DIR

# Save service account key to file temporarely
terraform output -raw sa_key_json_output | base64 --decode > ${CALL_DIR}/${GCP_KEY_FILE}

# Get GKE credentials for kubectl
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw location)

# Load secrets env vars
source ${CALL_DIR}/${SQL_CONN_ENV_FILE}


# ==== Back to initial working directory ====
cd $CALL_DIR

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
    --from-literal=uri=${SQL_CONNECTION_URI} \
    --namespace airflow

# Dataproc secrets
kubectl create secret generic gcp-dataproc \
    --from-literal=cluster=${DATAPROC_CLUSTER}
    --from-literal=job-name=${DATAPROC_JOB_NAME}
    --from-literal=region=${DATAPROC_REGION}
    --namespace airflow

kubectl create secret generic gcp-storage \
    --from-literal=raw=${STORAGE_RAW_BUCKET}
    --from-literal=staging=${STORAGE_STAGING_BUCKET}
    --namespace airflow

# Erase vars once they are stored as secrets
unset GCP_PROJECT_ID
unset GCP_CONNECTION_URI
unset SQL_SCHEMA
unset SQL_TABLE
unset SQL_CONNECTION_URI
unset DATAPROC_CLUSTER
unset DATAPROC_JOB_NAME
unset DATAPROC_REGION
unset STORAGE_RAW_BUCKET
unset STORAGE_STAGING_BUCKET
unset SQL_TYPE
unset SQL_PORT
unset SQL_HOST
unset SQL_LOGIN
unset SQL_PW
unset SQL_DB
unset SQL_INSTANCE

rm -f $GCP_KEY_FILE