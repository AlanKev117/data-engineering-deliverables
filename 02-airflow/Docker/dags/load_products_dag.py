import os

import airflow.utils.dates

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from gcs_to_postgres import GCSToPostgresTransfer

SQL_SCHEMA = os.environ["SQL_SCHEMA"]
SQL_TABLE = os.environ["SQL_TABLE"]

STORAGE_RAW_BUCKET = os.environ["STORAGE_RAW_BUCKET"]


default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1)
}

dag = DAG('load_products', default_args=default_args,
          schedule_interval='@daily')

process_dag = GCSToPostgresTransfer(
    task_id='dag_gcs_to_postgres',
    schema=SQL_SCHEMA,
    table=SQL_TABLE,
    gcs_bucket=STORAGE_RAW_BUCKET,
    gcs_key='user_purchase.csv',
    gcp_cloudsql_conn_id='google_cloud_sql_default',
    gcp_conn_id='google_cloud_default',
    dag=dag
)

process_dag
