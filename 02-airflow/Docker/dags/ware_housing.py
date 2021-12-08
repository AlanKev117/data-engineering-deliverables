import os

import airflow.utils.dates
from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

# get storage and bq data from env variables
PROJECT_ID = os.environ["PROJECT_ID"]
STAGING_BUCKET_URI = os.environ["STAGING_BUCKET_URI"]
DATASET = os.environ["BQ_DATASET"]
TABLE = os.environ["BQ_TABLE"]
OBJECT_NAME = "behavior_metrics.csv"

default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1)
}

dag = DAG('load_behavior_metrics',
          default_args=default_args, schedule_interval='@daily')


load_behavior_task = GCSToBigQueryOperator(
    task_id="load_to_warehouse",
    bucket=STAGING_BUCKET_URI,
    source_objects=f"{STAGING_BUCKET_URI}/{OBJECT_NAME}",
    destination_project_dataset_table=f"{PROJECT_ID}:{DATASET}.{TABLE}"
)

load_behavior_task
