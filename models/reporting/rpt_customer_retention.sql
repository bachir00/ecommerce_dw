with orders as (
    select * from {{ ref('fct_orders') }}
),

cohorts as (
    select
        customer_id,
        date_trunc('month', min(ordered_at))    as cohort_month
    from orders
    group by customer_id
),

customer_activity as (
    select
        orders.customer_id,
        cohorts.cohort_month,
        date_trunc('month', orders.ordered_at)  as activity_month,
        -- months since first purchase
        extract(
            epoch from date_trunc('month', orders.ordered_at) - cohorts.cohort_month
        ) / (60 * 60 * 24 * 30)                 as months_since_first_order
    from orders
    join cohorts using (customer_id)
)

select
    cohort_month,
    months_since_first_order,
    count(distinct customer_id)                                 as active_customers,
    first_value(count(distinct customer_id)) over (
        partition by cohort_month
        order by months_since_first_order
    )                                                           as cohort_size,
    round(
        count(distinct customer_id)::numeric /
        nullif(first_value(count(distinct customer_id)) over (
            partition by cohort_month
            order by months_since_first_order
        ), 0) * 100, 2
    )                                                           as retention_rate
from customer_activity
group by cohort_month, months_since_first_order
order by cohort_month, months_since_first_order
