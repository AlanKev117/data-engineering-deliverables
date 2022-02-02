from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.models import BaseOperator


class S3ToPostgresOperator(BaseOperator):
    """Moves small CSV files hosted on an S3 bucket to an RDB's Postgres table

    Overrides airflow.models.BaseOperator. Takes s3_key file that lives in
    s3_bucket to an RDS Postgres DB specific table and schema.

    Args:
        schema: pg schema to use
        table: pg table from schema that the S3 file will populate
        query: psql query to run
        s3_bucket: s3 bucket name that holds CSV file
        s3_key: s3 path inside bucket that leads to CSV file

    Template args:
        query: can be a path to sql query, such query may have jinja templates.
            It makes use of task's 'params' argument dictionary within SQL
            code:
                params.schema: the db schema to alter
                params.table: the table to populate with S3 CSV file
    """

    template_fields = ["query"]

    template_ext = [".sql"]

    ui_color = '#eaeaea'

    def __init__(
            self,
            schema: str,
            table: str,
            query: str,
            s3_bucket: str,
            s3_key: str,
            aws_postgres_conn_id: str = 'postgres_default',
            aws_conn_id: str = 'aws_default',
            *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.schema = schema
        self.table = table
        self.query = query
        self.s3_bucket = s3_bucket
        self.s3_key = s3_key
        self.aws_postgres_conn_id = aws_postgres_conn_id
        self.aws_conn_id = aws_conn_id

    def execute(self, context):

        # Local import for third party libraries
        import pandas as pd

        self.log.info("Connecting to AWS's Postgres via: ",
                      self.aws_postgres_conn_id)
        self.pg_hook = PostgresHook(postgres_conn_id=self.aws_postgres_conn_id)

        self.log.info("Connecting to AWS's S3 via: ", self.aws_conn_id)
        self.s3 = S3Hook(aws_conn_id=self.aws_conn_id)

        self.log.info("Downloading S3 object whose key is: ", self.s3_key)
        self.log.info("Hosted in: ", self.s3_bucket)

        # Try to download object.
        path_to_s3_file = self.s3.download_file(self.s3_key, self.s3_bucket)

        # Specific data type for some cols.
        int_cols = ['Quantity', 'CustomerID']
        float_cols = ['UnitPrice']
        date_cols = ['InvoiceDate']
        string_columns = ["InvoiceNo", "StockCode", "Description", "Country"]

        df_products = pd.read_csv(path_to_s3_file)
        self.log.info("CSV info: ", df_products.info())

        # drop nan values from customer id
        df_products = df_products[df_products["CustomerID"].notna()]

        # parsing correct data type
        for int_col in int_cols:
            df_products[int_col] = pd.to_numeric(
                df_products[int_col],
                errors="coerce",
                downcast="integer")
        for float_col in float_cols:
            df_products[float_col] = pd.to_numeric(
                df_products[float_col],
                errors="coerce",
                downcast="float")
        for date_col in date_cols:
            df_products[date_col] = pd.to_datetime(
                df_products[date_col],
                format="%m/%d/%Y %H:%M",
                errors="coerce")
        for string_column in string_columns:
            df_products[string_column] = df_products[string_column].str.strip()
            df_products[string_column] = df_products[string_column].str.replace(
                "\"", "")
        self.log.info("Dataset clean and columns parsed")

        # save df to csv file
        tmp_clean_csv_location = "user_purchase_clean.csv"
        df_products.to_csv(tmp_clean_csv_location, index=False)
        self.log.info("DF saved to CSV")

        self.log.info(f"SQL command to run prior to copy: {self.query}")

        # execute command to create table in postgres.
        self.pg_hook.run(self.query)
        self.log.info("Schema and table created")

        # execute command to send csv to sql
        self.pg_hook.run("SET datestyle = ISO;")
        self.pg_hook.copy_expert(
            f"COPY {self.schema}.{self.table} FROM STDIN WITH CSV HEADER",
            tmp_clean_csv_location)
