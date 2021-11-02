#!/bin/bash

# Admin user
airflow users create -u airflow -f Alan -l Fuentes -e fuentes.alan.98@gmail.com -r Admin -p airflow

# Initialize the metastore
airflow db init

# Connections
airflow connections delete google_cloud_default && airflow connections import /usr/local/airflow/custom_modules/assets/connections.json

# Run the scheduler in background
airflow scheduler &> /dev/null &

# Run the web server in foreground (for docker logs)
exec airflow webserver
