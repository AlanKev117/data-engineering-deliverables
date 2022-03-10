-- Which device is the most used to write reviews in the east and which one in the west?

WITH ranked_reviews_per_region AS (
    SELECT
        dl.region AS region,
        dd.device AS device,
        SUM(fma.review_count) as reviews,
        dense_rank() over(
            partition by dl.region
            order by
                SUM(fma.review_count) DESC
        ) as ranking
    FROM
        {{ params.athena_db }}.fact_movie_analytics fma
        INNER JOIN {{ params.athena_db }}.dim_location dl ON fma.id_dim_location = dl.id_dim_location
        INNER JOIN {{ params.athena_db }}.dim_device dd ON fma.id_dim_device = dd.id_dim_device
    GROUP BY
        dl.region,
        dd.device
)
SELECT
    *
FROM
    ranked_reviews_per_region rr
WHERE
    rr.ranking = 1;