-- Which location has more reviews from a computer in a Chrome browser?

SELECT
    SUM(fma.review_count) AS chrome_browser_reviews,
    dl.location AS location
FROM
    {{ params.athena_db }}.fact_movie_analytics fma
INNER JOIN
    {{ params.athena_db }}.dim_location dl ON fma.id_dim_location = dl.id_dim_location
INNER JOIN
    {{ params.athena_db }}.dim_device dd ON fma.id_dim_device = dd.id_dim_device
WHERE
    dd.browser = 'chrome'
GROUP BY
    dl.location
ORDER BY
    chrome_browser_reviews DESC
LIMIT 1;