with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select
        order_id,
        sum(amount)                                         as total_paid,
        max(payment_method)                                 as payment_method,
        bool_or(status = 'success')                        as is_paid
    from {{ ref('stg_payments') }}
    group by order_id
),

order_items as (
    select
        order_id,
        sum(line_total) as gross_revenue,
        sum(quantity)   as total_items
    from {{ ref('stg_order_items') }}
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.status,
    orders.ordered_at,
    cast(orders.ordered_at as date)     as order_date,
    order_items.gross_revenue,
    order_items.total_items,
    payments.total_paid,
    payments.payment_method,
    coalesce(payments.is_paid, false)   as is_paid
from orders
left join payments   using (order_id)
left join order_items using (order_id)
