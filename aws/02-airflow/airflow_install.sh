#!/bin/bash

# Save current worrking directory
CALL_DIR=$(pwd)

# Terraform directory
TERRAFORM_DIR=../01-terraform

cd $TERRAFORM_DIR

# Get AWS EKS cluster context
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
export NFS_SERVER=$(terraform output -raw efs)

cd $CALL_DIR

# Enable nfs server for cluster
kubectl create namespace storage
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace storage \
    --set nfs.server=$NFS_SERVER \
    --set nfs.path=/

# Install airflow
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow -n airflow -f values.yaml