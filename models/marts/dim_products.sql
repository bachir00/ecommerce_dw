with products as (
    select * from {{ ref('stg_products') }}
)

select
    product_id,
    product_name,
    category,
    brand,
    price,
    cost,
    price - cost as margin,
    round((price - cost) / nullif(price, 0) * 100, 2) as margin_pct
from products
