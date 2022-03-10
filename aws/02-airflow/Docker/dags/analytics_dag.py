import os

from airflow.utils.dates import days_ago
from airflow import DAG
from airflow.utils.task_group import TaskGroup
from airflow.models.variable import Variable
from airflow.providers.amazon.aws.operators.athena import AWSAthenaOperator
from airflow.providers.amazon.aws.sensors.athena import AthenaSensor

ATHENA_DATABASE = Variable.get("athdb")
S3_BUCKET = Variable.get("athbucket")
BUCKET = Variable.get("bucket")
S3_KEY = "outputs"

default_args = {
    'owner': 'alan.fuentes',
    'depends_on_past': False,
    'start_date': days_ago(1)
}

drop_external_metadata = [
    {
        "task_id": "setup__drop_external_movie_review",
        "sql": "ath_drop_external_movie_review.sql",
        "output_key": "drop_external_movie_review"
    },
    {
        "task_id": "setup__drop_external_user_purchase",
        "sql": "ath_drop_external_user_purchase.sql",
        "output_key": "drop_external_user_purchase"
    },
    {
        "task_id": "setup__drop_external_log_reviews",
        "sql": "ath_drop_external_log_reviews.sql",
        "output_key": "drop_external_log_reviews"
    },
    {
        "task_id": "setup__drop_external_fact_movie_analytics",
        "sql": "ath_drop_external_fact_movie_analytics.sql",
        "output_key": "drop_external_fact_movie_analytics"
    }
]

setup_external_metadata = [
    {
        "task_id": "setup__create_external_movie_review",
        "sql": "ath_create_external_movie_review.sql",
        "output_key": "create_external_movie_review",
        "location": f"s3://{BUCKET}/silver/movie_review"
    },
    {
        "task_id": "setup__create_external_user_purchase",
        "sql": "ath_create_external_user_purchase.sql",
        "output_key": "create_external_user_purchase",
        "location": f"s3://{BUCKET}/silver/user_purchase"
    },
    {
        "task_id": "setup__create_external_log_reviews",
        "sql": "ath_create_external_log_reviews.sql",
        "output_key": "create_external_log_reviews",
        "location": f"s3://{BUCKET}/silver/log_reviews"
    },
    {
        "task_id": "setup__create_external_fact_movie_analytics",
        "sql": "ath_create_external_fact_movie_analytics.sql",
        "output_key": "create_external_fact_movie_analytics",
        "location": f"s3://{BUCKET}/silver/fact_movie_analytics",
    }
]

drop_dims_metadata = [
    {
        "task_id": "setup__drop_dim_device",
        "sql": "ath_drop_dim_device.sql",
        "output_key": "drop_dim_device"
    },
    {
        "task_id": "setup__drop_dim_date",
        "sql": "ath_drop_dim_date.sql",
        "output_key": "drop_dim_device"
    },
    {
        "task_id": "setup__drop_dim_location",
        "sql": "ath_drop_dim_location.sql",
        "output_key": "drop_dim_location"
    }
]

setup_dims_metadata = [
    {
        "task_id": "setup__create_dim_device",
        "sql": "ath_create_dim_device.sql",
        "output_key": "create_dim_device"
    },
    {
        "task_id": "setup__create_dim_date",
        "sql": "ath_create_dim_date.sql",
        "output_key": "create_dim_device"
    },
    {
        "task_id": "setup__create_dim_location",
        "sql": "ath_create_dim_location.sql",
        "output_key": "create_dim_location"
    }
]

query_metadata = [
    {
        "task_id": "query__analytics_by_states",
        "sql": "ath_query_analytics_by_states.sql",
        "output_key": "query_analytics_by_states"
    },
    {
        "task_id": "query__analytics_by_device",
        "sql": "ath_query_analytics_by_device.sql",
        "output_key": "query_analytics_by_device"
    },
    {
        "task_id": "query__analytics_with_chrome",
        "sql": "ath_query_analytics_with_chrome.sql",
        "output_key": "query_analytics_with_chrome"
    },
    {
        "task_id": "query__analytics_top_bottom_states",
        "sql": "ath_query_analytics_top_bottom_states.sql",
        "output_key": "query_analytics_top_bottom_states"
    },
    {
        "task_id": "query__analytics_east_west",
        "sql": "ath_query_analytics_east_west.sql",
        "output_key": "query_analytics_east_west"
    }
]


with DAG('analytics_dag',
         default_args=default_args,
         template_searchpath=os.environ.get('ASSETS_DIR'),
         schedule_interval='@daily') as dag:

    with TaskGroup(group_id="setup_externals") as setup_externals:
        for drop_item, setup_item in zip(drop_external_metadata, setup_external_metadata):
            drop_task = AWSAthenaOperator(
                task_id=drop_item["task_id"],
                query=drop_item["sql"],
                database=ATHENA_DATABASE,
                output_location=f's3://{S3_BUCKET}/{S3_KEY}/{drop_item["output_key"]}',
                sleep_time=10,
                max_tries=None,
                params={"athena_db": ATHENA_DATABASE}
            )
            create_task = AWSAthenaOperator(
                task_id=setup_item["task_id"],
                query=setup_item["sql"],
                database=ATHENA_DATABASE,
                output_location=f's3://{S3_BUCKET}/{S3_KEY}/{setup_item["output_key"]}',
                sleep_time=10,
                max_tries=None,
                params={"athena_db": ATHENA_DATABASE,
                        "location": setup_item["location"]}
            )
            drop_task >> create_task

    partition_fact_table = AWSAthenaOperator(
        task_id="partition__fact_table",
        query="ath_add_partition_fact_table.sql",
        database=ATHENA_DATABASE,
        output_location=f's3://{S3_BUCKET}/{S3_KEY}/partition_fact_movie_analytics',
        sleep_time=10,
        max_tries=None,
        params={"athena_db": ATHENA_DATABASE,
                "location": f"s3://{BUCKET}/silver/fact_movie_analytics"}
    )

    wait_partition_fact_table = AthenaSensor(
        task_id="wait_ready_partition__fact_table",
        query_execution_id=partition_fact_table.output,
        max_retries=None,
        sleep_time=10,
    )

    with TaskGroup(group_id="setup_dims") as setup_dims:
        for drop_item, setup_item in zip(drop_dims_metadata, setup_dims_metadata):
            drop_task = AWSAthenaOperator(
                task_id=drop_item["task_id"],
                query=drop_item["sql"],
                database=ATHENA_DATABASE,
                output_location=f's3://{S3_BUCKET}/{S3_KEY}/{drop_item["output_key"]}',
                sleep_time=10,
                max_tries=None,
                params={"athena_db": ATHENA_DATABASE}
            )

            task = AWSAthenaOperator(
                task_id=setup_item["task_id"],
                query=setup_item["sql"],
                database=ATHENA_DATABASE,
                output_location=f's3://{S3_BUCKET}/{S3_KEY}/{setup_item["output_key"]}',
                sleep_time=10,
                max_tries=None,
                params={"athena_db": ATHENA_DATABASE}
            )

            wait_task = AthenaSensor(
                task_id="wait_ready_" + setup_item["task_id"],
                query_execution_id=task.output,
                max_retries=None,
                sleep_time=10,
            )

            drop_task >> task >> wait_task

    with TaskGroup(group_id="queries") as queries:
        for query_item in query_metadata:
            query_task = AWSAthenaOperator(
                task_id=query_item["task_id"],
                query=query_item["sql"],
                database=ATHENA_DATABASE,
                output_location=f's3://{S3_BUCKET}/{S3_KEY}/{query_item["output_key"]}',
                sleep_time=10,
                max_tries=None,
                params={"athena_db": ATHENA_DATABASE}
            )

            wait_task = AthenaSensor(
                task_id="wait_ready_" + query_item["task_id"],
                query_execution_id=query_task.output,
                max_retries=None,
                sleep_time=10,
            )

            query_task >> wait_task

(
    setup_externals
    >> partition_fact_table
    >> wait_partition_fact_table
    >> setup_dims
    >> queries
)
