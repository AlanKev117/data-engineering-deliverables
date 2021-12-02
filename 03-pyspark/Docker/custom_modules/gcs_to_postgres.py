import io
import re
import os
from pathlib import Path

import pandas as pd
import psycopg2
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from airflow.exceptions import AirflowException
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.providers.google.cloud.hooks.cloud_sql import CloudSQLDatabaseHook


class GCSToPostgresTransfer(BaseOperator):
    """GCSToPostgresTransfer: custom operator created to move small CSV files
        from GCS to a PostgresSQL database instance.

        Author: Juan Escobar
        Edited by: Alan Fuentes
        Creation Date: 20/09/2021
        Edition date: 29/10/2021
    """

    template_fields = ()

    template_ext = ()

    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            schema,
            table,
            gcs_bucket,
            gcs_key,
            gcp_cloudsql_conn_id='google_cloud_sql_default',
            gcp_conn_id='google_cloud_default',
            verify=None,
            wildcard_match=False,
            copy_options=tuple(),
            autocommit=False,
            parameters=None,
            *args, **kwargs):
        super(GCSToPostgresTransfer, self).__init__(*args, **kwargs)
        self.schema = schema
        self.table = table
        self.gcs_bucket = gcs_bucket
        self.gcs_key = gcs_key
        self.gcp_cloudsql_conn_id = gcp_cloudsql_conn_id
        self.gcp_conn_id = gcp_conn_id
        self.verify = verify
        self.wildcard_match = wildcard_match
        self.copy_options = copy_options
        self.autocommit = autocommit
        self.parameters = parameters

    def execute(self, context):

        # Create an instances to connect S3 and Postgres DB.
        self.log.info(self.gcp_cloudsql_conn_id)

        gcp_hook = CloudSQLDatabaseHook(
            gcp_cloudsql_conn_id=self.gcp_cloudsql_conn_id, gcp_conn_id=self.gcp_conn_id)
        self.pg_hook = gcp_hook.get_database_hook(
            connection=gcp_hook.create_connection())
        self.gcs = GCSHook(gcp_conn_id=self.gcp_conn_id)

        self.log.info("Downloading GCS file")
        self.log.info(self.gcs_key + ', ' + self.gcs_bucket)

        # Download file from GCS.
        csv_content = self.gcs.download(self.gcs_bucket, self.gcs_key)

        # Read and decode the file into a string
        csv_str_content = csv_content.decode(encoding="utf-8", errors="ignore")

        # Specific data type for some cols.
        int_cols = ['Quantity', 'CustomerID']
        float_cols = ['UnitPrice']
        date_cols = ['InvoiceDate']
        string_columns = ["InvoiceNo", "StockCode", "Description", "Country"]

        # read a csv file with the properties required.
        df_products = pd.read_csv(io.StringIO(csv_str_content))
        self.log.info(df_products)
        self.log.info(df_products.info())

        # drop nan values from customer id
        df_products = df_products[df_products["CustomerID"].notna()]

        # parsing correct data type
        for int_col in int_cols:
            df_products[int_col] = pd.to_numeric(
                df_products[int_col], errors="coerce", downcast="integer")
        for float_col in float_cols:
            df_products[float_col] = pd.to_numeric(
                df_products[float_col], errors="coerce", downcast="float")
        for date_col in date_cols:
            df_products[date_col] = pd.to_datetime(
                df_products[date_col], format="%m/%d/%Y %H:%M", errors="coerce")

        self.log.info("Columns parsed")

        # formatting the dataframe.
        for string_column in string_columns:
            df_products[string_column] = df_products[string_column].str.strip()
            df_products[string_column] = df_products[string_column].str.replace(
                "\"", "")

        # save df to csv file.
        self.log.info("Dataset clean")

        tmp_clean_csv_location = "user_purchase_clean.csv"
        df_products.to_csv(tmp_clean_csv_location, index=False)
        self.log.info("DF saved to CSV")

        # Read the file with the DDL SQL to create the table products in postgres DB.
        query_file_path = Path(os.environ["PG_QUERY_PATH"])
        self.log.info(f"Query located at: {query_file_path}")

        # ISO-8859-1 codificación preferidad por
        # Microsoft, en Linux es UTF-8
        encoding = "UTF-8"

        with open(query_file_path, "r", encoding=encoding) as query_file:

            # Read dile with the DDL CREATE TABLE
            sql_command = query_file.read()

            # Display the content
            self.log.info(f"SQL command to run: {sql_command}")

        # execute command to create table in postgres.
        self.pg_hook.run(sql_command)
        self.log.info("Schema and table created")

        # execute command to send csv to sql
        self.pg_hook.run("SET datestyle = ISO;")
        self.pg_hook.copy_expert(
            f"COPY {schema}.{table} FROM STDIN WITH CSV HEADER", tmp_clean_csv_location)
