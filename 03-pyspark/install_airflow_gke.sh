#!/bin/bash

# Get cluster endpoint to kubectl (connection)
# gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw location)
# gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region us-central1-a

# Create namespace for airflow
kubectl create namespace airflow

# Add airflow chart repository for helm
helm repo add apache-airflow https://airflow.apache.org

# Use the repo to install airflow to cluster
helm install airflow -f airflow-values.yaml apache-airflow/airflow --namespace airflow