with order_items as (
    select * from {{ ref('fct_order_items') }}
)

select
    date_trunc('month', ordered_at)     as month,
    category,
    brand,
    count(distinct order_id)            as nb_orders,
    sum(quantity)                       as units_sold,
    round(sum(line_total)::numeric, 2)  as gross_revenue,
    round(sum(line_margin)::numeric, 2) as gross_margin
from order_items
where status != 'cancelled'
group by 1, 2, 3
order by 1 desc, gross_revenue desc
