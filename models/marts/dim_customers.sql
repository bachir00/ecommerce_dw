with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select
        customer_id,
        min(ordered_at) as first_order_at,
        max(ordered_at) as last_order_at,
        count(order_id)  as total_orders
    from {{ ref('stg_orders') }}
    group by customer_id
)

select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.country,
    customers.registered_at,
    orders.first_order_at,
    orders.last_order_at,
    coalesce(orders.total_orders, 0) as total_orders
from customers
left join orders using (customer_id)
