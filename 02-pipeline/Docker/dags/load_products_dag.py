import airflow.utils.dates

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from gcs_to_postgres import GCSToPostgresTransfer

default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1)
}

dag = DAG('dag_insert_data', default_args=default_args,
          schedule_interval='@daily')

process_dag = GCSToPostgresTransfer(
    task_id='dag_gcs_to_postgres',
    schema='raw_data',
    table='user_purchase',
    gcs_bucket='raw_zone_de_af',
    gcs_key='user_purchase.csv',
    gcp_cloudsql_conn_id='google_cloud_sql_default',
    gcp_conn_id='google_cloud_default',
    dag=dag
)

process_dag
