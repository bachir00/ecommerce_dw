WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

items AS (
    SELECT
        order_id,
        COUNT(*)                AS item_count,
        SUM(price)              AS subtotal,
        SUM(freight_value)      AS shipping_total,
        SUM(total_item_value)   AS order_total
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

payments AS (
    SELECT
        order_id,
        payment_type,
        payment_installments,
        SUM(payment_value)      AS total_payment
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id, payment_type, payment_installments
),

reviews AS (
    SELECT * FROM {{ ref('stg_reviews') }}
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.approved_date,
    o.delivered_date,
    o.order_status,
    o.delivery_days,
    o.delivered_on_time,
    i.item_count,
    ROUND(i.subtotal, 2)        AS subtotal,
    ROUND(i.shipping_total, 2)  AS shipping_total,
    ROUND(i.order_total, 2)     AS order_total,
    p.payment_type,
    p.payment_installments,
    r.review_score,
    r.sentiment
FROM orders o
LEFT JOIN items    i ON o.order_id = i.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews  r ON o.order_id = r.order_id