#!/bin/bash

# Save current worrking directory
CALL_DIR=$(pwd)

# Terraform directory
TERRAFORM_DIR=../01-terraform

cd $TERRAFORM_DIR

# Get AWS EKS cluster context
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
export NFS_SERVER=$(terraform output -raw efs)

# Secrets env vars (airflow vars and connections) to inject to pods
# using Terraform output data (make sure AWS access key CSV file is in TERRAFORM_DIR)
CREDENTIALS_FILE=$(find ./*accessKeys.csv)
CREDENTIALS=$(head -2 $CREDENTIALS_FILE | tail -1)
AFCONN_AWS="aws://${CREDENTIALS/,/:}@"

DB_USER=$(terraform output -raw rds_username)
DB_PASSWORD=$(terraform output -raw rds_password)
DB_ENDPOINT=$(terraform output -raw rds_endpoint)
DB_NAME=$(terraform output -raw rds_database)
AFCONN_POSTGRES="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"

AFVAR_BUCKET=$(terraform output -raw s3_bucket_name)
AFVAR_LOGREV_KEY=$(terraform output -raw s3_csv_log_reviews_key)
AFVAR_MOVREV_KEY=$(terraform output -raw s3_csv_movie_review_key)
AFVAR_USRPUR_KEY=$(terraform output -raw s3_csv_user_purchase_key)
AFVAR_USRPUR_TABLE="user_purchase"
AFVAR_USRPUR_SCHEMA="raw_data"
AFVAR_USRPUR_QUERY="create_schema_and_table.sql"  # must match file name in Docker image.
AFVAR_GLUEJOB=$(terraform output -raw gj_name)
AFVAR_REGION=$(terraform output -raw region)

cd $CALL_DIR

# Enable nfs server for cluster
kubectl create namespace storage
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace storage \
    --set nfs.server=$NFS_SERVER \
    --set nfs.path=/

# Create airflow namespace
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org

# Inject env vars calculated earlier as secrets
kubectl create secret generic af-connections \
    --from-literal=aws=${AFCONN_AWS} \
    --from-literal=postgres=${AFCONN_POSTGRES} \
    --namespace airflow

kubectl create secret generic af-variables \
    --from-literal=bucket=${AFVAR_BUCKET} \
    --from-literal=logrev_key=${AFVAR_LOGREV_KEY} \
    --from-literal=movrev_key=${AFVAR_MOVREV_KEY} \
    --from-literal=usrpur_key=${AFVAR_USRPUR_KEY} \
    --from-literal=usrpur_table=${AFVAR_USRPUR_TABLE} \
    --from-literal=usrpur_schema=${AFVAR_USRPUR_SCHEMA} \
    --from-literal=usrpur_query=${AFVAR_USRPUR_QUERY} \
    --from-literal=gluejob=${AFVAR_GLUEJOB} \
    --from-literal=region=${AFVAR_REGION} \
    --namespace airflow

# Install airflow after secrets set
helm install airflow apache-airflow/airflow -n airflow -f values.yaml
