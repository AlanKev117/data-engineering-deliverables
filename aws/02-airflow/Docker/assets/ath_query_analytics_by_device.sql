-- How many reviews were done in California, NY, and Texas with an apple device? And how many for each device type?

SELECT
    SUM(fma.review_count) AS apple_os_reviews_in_CA_NY_TX,
    dd.device AS device_type
FROM
    {{ params.athena_db }}.fact_movie_analytics fma
INNER JOIN
    {{ params.athena_db }}.dim_location dl ON fma.id_dim_location = dl.id_dim_location
INNER JOIN
    {{ params.athena_db }}.dim_device dd ON fma.id_dim_device = dd.id_dim_device
WHERE
    dl.location IN ('California', 'New York', 'Texas')
AND
    LOWER(dd.os) LIKE '%apple%'
GROUP BY
    dd.device;