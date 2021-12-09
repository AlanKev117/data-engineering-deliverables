import os

import airflow.utils.dates
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.gcs import GCSListObjectsOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateExternalTableOperator

# get storage and bq data from env variables
PROJECT_ID = os.environ["GCP_PROJECT_ID"]
STORAGE_STAGING_BUCKET = os.environ["STORAGE_STAGING_BUCKET"]
DATASET_NAME = os.environ["BQ_DATASET_NAME"]

TABLE = "metrics"

default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1),
}

dag = DAG('load_analytics',
          default_args=default_args,
          render_template_as_native_obj=True,
          schedule_interval='@daily')


get_parquet_files_task = GCSListObjectsOperator(
    task_id="get_parquet_files_task",
    bucket=STORAGE_STAGING_BUCKET,
    prefix="behavior_metrics/",
    delimiter=".parquet",
    dag=dag
)

def format_parquet_uris(parquet_uris):
    return [f"gs://{STORAGE_STAGING_BUCKET}/{parquet_uri}" for parquet_uri in parquet_uris]

format_parquet_uris_task = PythonOperator(
    task_id="format_parquet_uris_task",
    python_callable=format_parquet_uris,
    op_kwargs={"parquet_uris": "{{ task_instance.xcom_pull(task_ids='get_parquet_files_task') }}"},
    dag=dag
)

create_external_table_task = BigQueryCreateExternalTableOperator(
    task_id="create_external_table_task",
    table_resource={
        "tableReference": {
            "projectId": PROJECT_ID,
            "datasetId": DATASET_NAME,
            "tableId": "behavior_metrics_et",
        },
        "externalDataConfiguration": {
            "sourceFormat": "PARQUET",
            "compression": "NONE",
            "sourceUris": "{{ task_instance.xcom_pull(task_ids='format_parquet_uris_task') }}",
        },
    },
    dag=dag
)


get_parquet_files_task >> format_parquet_uris_task >> create_external_table_task
