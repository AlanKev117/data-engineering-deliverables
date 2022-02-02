#!/bin/bash

if [ -z "$1" ]
then
    echo "No newer tag for airflow image provided"
    exit -1
fi

# Build new version
cd ./Docker
IMAGE=fugalkev/airflow-aws
FULL_IMAGE=$IMAGE:$1
docker build -t $FULL_IMAGE . && docker push $FULL_IMAGE

# Uninstall previous version
helm delete airflow -n airflow
AIRFLOW_VOID_STRING=""

# Wait until all airflow pods are down
until [ "${AIRFLOW_VOID_STRING}" = "No resources found in airflow namespace." ]
do
    AIRFLOW_VOID_STRING=$(kubectl get pods -n airflow 2>&1)
done

# Install new version
helm install airflow apache-airflow/airflow -n airflow \
    --set images.airflow.repository=$IMAGE \
    --set images.airflow.tag=$1

echo "Upgraded airflow: dont forget to update values.yml image tag"