CREATE TABLE {{ params.athena_db }}.dim_date AS
SELECT
    lr.log_date AS id_dim_date,
    lr.log_date AS log_date,
    DAY(lr.log_date) AS day,
    MONTH(lr.log_date) AS month,
    YEAR(lr.log_date) AS year,
    CASE
        WHEN MONTH(lr.log_date) in (12, 1, 2) THEN 'winter'
        WHEN MONTH(lr.log_date) in (3, 4, 5) THEN 'spring'
        WHEN MONTH(lr.log_date) in (6, 7, 8) THEN 'summer'
        WHEN MONTH(lr.log_date) in (9, 10, 11) THEN 'autumn'
    END AS season
FROM
    {{ params.athena_db }}.log_reviews lr
GROUP BY
    lr.log_date;