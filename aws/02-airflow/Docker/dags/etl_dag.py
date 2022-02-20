from airflow.utils.dates import days_ago
from airflow import DAG
from airflow.models.variable import Variable
from airflow.hooks.base import BaseHook
from airflow.providers.amazon.aws.operators.glue import AwsGlueJobOperator


GLUE_JOB_NAME = Variable.get("gluejob")
USRPUR_SCHEMA = Variable.get("usrpur_schema")
USRPUR_TABLE = Variable.get("usrpur_table")
MOVREV_KEY = Variable.get("movrev_key")
LOGREV_KEY = Variable.get("logrev_key")
BUCKET = Variable.get("bucket")
REGION = Variable.get("region")

pg_conn = BaseHook.get_connection("postgres_default")

default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': days_ago(1)
}

script_args = {
    "--db_endpoint": f"{pg_conn.host}:{pg_conn.port}",
    "--db_name": pg_conn.schema,
    "--db_table": f"{USRPUR_SCHEMA}.{USRPUR_TABLE}",
    "--db_user": pg_conn.login,
    "--db_password": pg_conn.password,
    "--movie_rev_path": f"s3://{BUCKET}/{MOVREV_KEY}",
    "--log_rev_path": f"s3://{BUCKET}/{LOGREV_KEY}",
    "--staging_path": f"s3://{BUCKET}/staging"
}

with DAG('etl_dag',
         default_args=default_args,
         schedule_interval='@daily') as dag:
    etl = AwsGlueJobOperator(task_id="glue_job_task",
                             job_name=GLUE_JOB_NAME,
                             script_args=script_args,
                             region_name=REGION)

etl
