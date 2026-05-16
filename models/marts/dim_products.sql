WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

sales AS (
    SELECT
        product_id,
        COUNT(*)        AS times_ordered,
        SUM(price)      AS total_revenue,
        AVG(price)      AS avg_price
    FROM {{ ref('stg_order_items') }}
    GROUP BY 1
)

SELECT
    p.product_id,
    p.product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    s.times_ordered,
    ROUND(s.total_revenue, 2)   AS total_revenue,
    ROUND(s.avg_price, 2)       AS avg_price
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id