-- What are the states with more and fewer reviews in 2021?
WITH ranked_reviews_per_state AS (
    SELECT
        dl.location AS location,
        SUM(fma.review_count) AS total_reviews_2021,
        row_number() over(order by SUM(fma.review_count) DESC) as ranking_top,
        row_number() over(order by SUM(fma.review_count)) as ranking_bottom

    FROM
        {{ params.athena_db }}.fact_movie_analytics fma
        INNER JOIN {{ params.athena_db }}.dim_location dl ON fma.id_dim_location = dl.id_dim_location
        INNER JOIN {{ params.athena_db }}.dim_date dd ON fma.id_dim_date = dd.id_dim_date
    WHERE
        dd.year = 2021
    GROUP BY
        dl.location
)
SELECT
    location,
    total_reviews_2021,
    CASE
        WHEN ranking_top = 1 THEN 'top'
        WHEN ranking_bottom = 1 THEN 'bottom'
    END AS position
FROM
    ranked_reviews_per_state
WHERE
    ranking_top = 1 
    OR ranking_bottom = 1
ORDER BY total_reviews_2021 DESC;