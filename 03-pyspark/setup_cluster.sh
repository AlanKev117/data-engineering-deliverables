#!/bin/bash

# clone repo in cluster
git clone https://github.com/AlanKev117/data-engineering-deliverables.git
cd data-engineering-deliverables

# Move assets to the right place
[ ! -d "/usr/local/airflow" ] && mkdir -p /usr/local/airflow
mv ./02-pipeline/Docker/custom_modules /usr/local/airflow

# install python dependencies
pip install -r ./02-pipeline/Docker/requirements/requirements.txt

