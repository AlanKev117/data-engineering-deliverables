CREATE EXTERNAL TABLE IF NOT EXISTS {{ params.athena_db }}.movie_review (
    customer_id INT,
    positive_review INT,
    review_id INT
)
STORED AS PARQUET
LOCATION '{{ params.location }}';