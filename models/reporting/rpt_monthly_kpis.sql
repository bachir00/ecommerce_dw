WITH orders AS (
    SELECT * FROM {{ ref('fct_orders') }}
),

dates AS (
    SELECT * FROM {{ ref('dim_date') }}
)

SELECT
    d.year_month,
    d.year,
    d.month,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COUNT(DISTINCT o.customer_id)       AS unique_customers,
    ROUND(SUM(o.order_total), 2)        AS total_revenue,
    ROUND(AVG(o.order_total), 2)        AS avg_order_value,
    ROUND(AVG(o.review_score), 2)       AS avg_review_score,
    ROUND(AVG(o.delivery_days), 1)      AS avg_delivery_days,
    SUM(CASE WHEN o.delivered_on_time
        THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)              AS on_time_delivery_rate
FROM dates d
JOIN orders o ON d.date_day = o.order_date
GROUP BY 1, 2, 3
ORDER BY 1