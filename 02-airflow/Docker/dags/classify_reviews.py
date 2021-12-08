import os

import airflow.utils.dates
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitJobOperator
from airflow.hooks.base import BaseHook

# get dataproc data from env variables
GCP_PROJECT_ID = os.environ["GCP_PROJECT_ID"]

SQL_SCHEMA = os.environ["SQL_SCHEMA"]

DATAPROC_JOB_NAME = os.environ["DATAPROC_JOB_NAME"]
DATAPROC_REGION = os.environ["DATAPROC_REGION"]
DATAPROC_CLUSTER = os.environ["DATAPROC_CLUSTER"]

STORAGE_RAW_BUCKET = os.environ["STORAGE_RAW_BUCKET"]
STORAGE_STAGING_BUCKET = os.environ["STORAGE_STAGING_BUCKET"]

# safely fetch sensitive connection data
cloud_sql_connection = BaseHook.get_connection("google_cloud_sql_default")
HOST = cloud_sql_connection.host
PORT = cloud_sql_connection.port
LOGIN = cloud_sql_connection.login
PW = cloud_sql_connection.password
DATABASE = cloud_sql_connection.schema

TABLE = 'user_purchase'

ARGS = ["--host", HOST,
        "--port", PORT,
        "--user", LOGIN,
        "--pw", PW,
        "--db", DATABASE,
        "--schema", SQL_SCHEMA,
        "--table", TABLE,
        "--raw-bucket", f"gs://{STORAGE_RAW_BUCKET}",
        "--staging-bucket", f"gs://{STORAGE_STAGING_BUCKET}"]

PYSPARK_JOB = {
    "placement": {"cluster_name": DATAPROC_CLUSTER},
    "pyspark_job": {
        "jar_file_uris": ["https://jdbc.postgresql.org/download/postgresql-42.3.1.jar"],
        "main_python_file_uri": f"gs://{STORAGE_RAW_BUCKET}/{DATAPROC_JOB_NAME}",
        "args": ARGS
    }
}


default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1)
}

dag = DAG('movie_review_classification',
          default_args=default_args, schedule_interval='@daily')


submit_pyspark_job = DataprocSubmitJobOperator(
    task_id="review_classification",
    job=PYSPARK_JOB,
    region=DATAPROC_REGION,
    project_id=GCP_PROJECT_ID
)

submit_pyspark_job
