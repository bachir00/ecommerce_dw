with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select order_id, customer_id, ordered_at, status
    from {{ ref('stg_orders') }}
),

products as (
    select product_id, category, brand, cost
    from {{ ref('stg_products') }}
)

select
    order_items.order_item_id,
    order_items.order_id,
    orders.customer_id,
    order_items.product_id,
    products.category,
    products.brand,
    orders.ordered_at,
    cast(orders.ordered_at as date)                             as order_date,
    order_items.quantity,
    order_items.unit_price,
    order_items.line_total,
    order_items.line_total - (products.cost * order_items.quantity) as line_margin,
    orders.status
from order_items
left join orders  using (order_id)
left join products using (product_id)
