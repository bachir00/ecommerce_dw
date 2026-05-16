WITH items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

products AS (
    SELECT * FROM {{ ref('dim_products') }}
)

SELECT
    p.product_category_name,
    COUNT(DISTINCT i.order_id)      AS total_orders,
    COUNT(i.order_item_id)          AS units_sold,
    ROUND(SUM(i.price), 2)          AS total_revenue,
    ROUND(AVG(i.price), 2)          AS avg_price,
    ROUND(SUM(i.freight_value), 2)  AS total_shipping
FROM items i
JOIN products p ON i.product_id = p.product_id
GROUP BY 1
ORDER BY total_revenue DESC