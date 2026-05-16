WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT
        customer_id,
        COUNT(*)            AS total_orders,
        MIN(order_date)     AS first_order_date,
        MAX(order_date)     AS last_order_date
    FROM {{ ref('stg_orders') }}
    GROUP BY 1
)

SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.total_orders,
    o.first_order_date,
    o.last_order_date,
    DATEDIFF('day',
        o.first_order_date,
        o.last_order_date
    )                       AS customer_lifetime_days,
    CASE
        WHEN o.total_orders = 1  THEN 'one_time'
        WHEN o.total_orders <= 3 THEN 'occasional'
        ELSE 'loyal'
    END                     AS customer_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id