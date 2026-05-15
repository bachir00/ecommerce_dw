with orders as (
    select * from {{ ref('fct_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
)

select
    date_trunc('month', ordered_at)             as month,

    -- volume
    count(distinct order_id)                    as total_orders,
    count(distinct customer_id)                 as active_customers,
    sum(total_items)                            as units_sold,

    -- revenue
    round(sum(gross_revenue)::numeric, 2)       as gross_revenue,
    round(sum(total_paid)::numeric, 2)          as net_revenue,
    round(avg(gross_revenue)::numeric, 2)       as avg_order_value,

    -- new vs returning
    count(distinct case
        when date_trunc('month', ordered_at) = date_trunc('month', customers.first_order_at)
        then orders.customer_id
    end)                                        as new_customers,

    count(distinct case
        when date_trunc('month', ordered_at) > date_trunc('month', customers.first_order_at)
        then orders.customer_id
    end)                                        as returning_customers,

    -- quality
    round(
        100.0 * count(case when status = 'cancelled' then 1 end)
        / nullif(count(*), 0), 2
    )                                           as cancellation_rate_pct

from orders
left join customers using (customer_id)
where orders.ordered_at is not null
group by 1
order by 1 desc
