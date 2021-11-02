CREATE SCHEMA IF NOT EXISTS second_deliverable;

CREATE TABLE IF NOT EXISTS second_deliverable.user_purchase (
    invoice_number VARCHAR(10),
    stock_code VARCHAR(20),
    detail VARCHAR(1000),
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(8, 3),
    customer_id INT,
    country VARCHAR(20)
);

TRUNCATE TABLE second_deliverable.user_purchase;