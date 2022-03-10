-- How many reviews were done in California, NY and Texas?

SELECT
    SUM(fma.review_count) AS reviews_in_CA_NY_TX
FROM
    {{ params.athena_db }}.fact_movie_analytics fma
INNER JOIN
    {{ params.athena_db }}.dim_location dl USING (id_dim_location)
WHERE
    dl.location IN ('California', 'New York', 'Texas');