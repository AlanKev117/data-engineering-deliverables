CREATE SCHEMA IF NOT EXISTS {{ params.schema }};

CREATE TABLE IF NOT EXISTS {{ var.value.SQL_SCHEMA }}.{{ params.table }} (
    invoice_number VARCHAR(10),
    stock_code VARCHAR(20),
    detail VARCHAR(1000),
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(8, 3),
    customer_id INT,
    country VARCHAR(20)
);

TRUNCATE TABLE {{ var.value.SQL_SCHEMA }}.{{ var.value.SQL_TABLE }};
