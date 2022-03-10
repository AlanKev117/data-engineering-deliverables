CREATE EXTERNAL TABLE IF NOT EXISTS {{ params.athena_db }}.log_reviews (
    log_id INT,
    log_date DATE,
    device VARCHAR(10),
    os VARCHAR(20),
    location VARCHAR(30),
    browser VARCHAR(10),
    ip VARCHAR(16),
    phone_number VARCHAR(13)
)
STORED AS PARQUET
LOCATION '{{ params.location }}';