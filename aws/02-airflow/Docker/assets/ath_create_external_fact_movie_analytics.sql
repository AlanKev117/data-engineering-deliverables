CREATE EXTERNAL TABLE IF NOT EXISTS {{ params.athena_db }}.fact_movie_analytics (
    id_fact_movie_analytics INT,
    id_dim_date DATE,
    id_dim_device VARCHAR(6),
    amount_spent DECIMAL(8, 3),
    review_score INT,
    review_count INT
)
PARTITIONED BY (id_dim_location VARCHAR(3))
STORED AS PARQUET
LOCATION '{{ params.location }}';