CREATE EXTERNAL TABLE IF NOT EXISTS {{ params.athena_db }}.user_purchase (
    invoice_number VARCHAR(10),
    stock_code VARCHAR(20),
    detail VARCHAR(1000),
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price DECIMAL(8, 3),
    customer_id INT,
    country VARCHAR(20)
)
STORED AS PARQUET
LOCATION '{{ params.location }}';