import os

from airflow.utils.dates import days_ago
from airflow import DAG
from airflow.models.variable import Variable

from custom_modules.operators.s3_to_postgres_operator import S3ToPostgresOperator

SQL_SCHEMA = Variable.get("SQL_SCHEMA", "my_schema")
SQL_TABLE = Variable.get("SQL_TABLE", "my_table")
SQL_QUERY =  Variable.get("SQL_QUERY", "query.sql")

CSV_BUCKET = Variable.get("CSV_BUCKET", "my_bucket")
CSV_FILE = Variable.get("CSV_FILE", "my_file")


default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': days_ago(1)
}

with DAG('extract_products', 
    default_args=default_args,
    template_searchpath=os.environ.get('ASSETS_DIR'),
    schedule_interval='@daily') as dag:
    load_file = S3ToPostgresOperator(
        task_id='s3_to_postgres_task',
        schema=SQL_SCHEMA,
        table=SQL_TABLE,
        query=SQL_QUERY,
        s3_bucket=CSV_BUCKET,
        s3_key=CSV_FILE,
        params={"schema": SQL_SCHEMA, "table": SQL_TABLE}
    )

load_file
