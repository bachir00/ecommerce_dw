WITH date_spine AS (
    SELECT
        DATEADD('day', ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1,
            '2016-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1500))
)

SELECT
    date_day,
    YEAR(date_day)                  AS year,
    MONTH(date_day)                 AS month,
    DAY(date_day)                   AS day,
    QUARTER(date_day)               AS quarter,
    DAYOFWEEK(date_day)             AS day_of_week,
    DAYNAME(date_day)               AS day_name,
    MONTHNAME(date_day)             AS month_name,
    TO_CHAR(date_day, 'YYYY-MM')    AS year_month,
    CASE
        WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE
        ELSE FALSE
    END                             AS is_weekend
FROM date_spine