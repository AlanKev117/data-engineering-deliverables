CREATE TABLE {{ params.athena_db }}.dim_device AS
SELECT
    CONCAT(
        CASE
            lr.device
            WHEN 'Mobile' THEN 'M'
            WHEN 'Computer' THEN 'C'
            WHEN 'Tablet' THEN 'T'
        END,
        '_',
        CASE
            lr.os
            WHEN 'Apple iOS' THEN 'I'
            WHEN 'Linux' THEN 'L'
            WHEN 'Apple MacOS' THEN 'M'
            WHEN 'Google Android' THEN 'A'
            WHEN 'Microsoft Windows' THEN 'W'
        END,
        '_',
        CASE
            lr.browser
            WHEN 'chrome' THEN 'C'
            WHEN 'edge' THEN 'E'
            WHEN 'firefox' THEN 'F'
            WHEN 'safari' THEN 'S'
        END
    ) AS id_dim_device,
    lr.device AS device,
    lr.os AS os,
    lr.browser AS browser
FROM
    {{ params.athena_db }}.log_reviews lr
GROUP BY
    lr.device,
    lr.os,
    lr.browser;