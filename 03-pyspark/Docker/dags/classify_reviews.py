import os

import airflow.utils.dates
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitJobOperator
from airflow.hooks.base import BaseHook

# get dataproc data from env variables
PROJECT_ID = os.environ["PROJECT_ID"]
CLUSTER_NAME = os.environ["CLUSTER_NAME"]
MAIN_JOB_URI = os.environ["MAIN_JOB_URI"]
RAW_BUCKET_URI = os.environ["RAW_BUCKET_URI"]
STAGING_BUCKET_URI = os.environ["STAGING_BUCKET_URI"]
CLUSTER_REGION = os.environ["CLUSTER_REGION"]
SCHEMA = os.environ["DB_SCHEMA"]

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
        "--schema", SCHEMA,
        "--table", TABLE,
        "--raw-bucket", RAW_BUCKET_URI,
        "--staging-bucket", STAGING_BUCKET_URI]

PYSPARK_JOB = {
    "placement": {"cluster_name": CLUSTER_NAME},
    "pyspark_job": {
        "jar_file_uris": ["https://jdbc.postgresql.org/download/postgresql-42.3.1.jar"],
        "main_python_file_uri": MAIN_JOB_URI,
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
    region=CLUSTER_REGION,
    project_id=PROJECT_ID
)

submit_pyspark_job
