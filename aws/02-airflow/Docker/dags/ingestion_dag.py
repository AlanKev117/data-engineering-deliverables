import os

from airflow.utils.dates import days_ago
from airflow import DAG
from airflow.models.variable import Variable

from custom_modules.operators.s3_to_postgres_operator import S3ToPostgresOperator

SQL_SCHEMA = Variable.get("usrpur_schema")
SQL_TABLE = Variable.get("usrpur_table")
SQL_QUERY = Variable.get("usrpur_query")

CSV_BUCKET = Variable.get("bucket")
CSV_FILE = Variable.get("usrpur_key")


default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': days_ago(1)
}

with DAG('ingestion_dag',
         default_args=default_args,
         template_searchpath=os.environ.get('ASSETS_DIR'),
         schedule_interval='@daily') as dag:
    ingestion = S3ToPostgresOperator(
        task_id='s3_to_postgres_task',
        schema=SQL_SCHEMA,
        table=SQL_TABLE,
        query=SQL_QUERY,
        s3_bucket=CSV_BUCKET,
        s3_key=CSV_FILE,
        params={"schema": SQL_SCHEMA, "table": SQL_TABLE}
    )

ingestion
