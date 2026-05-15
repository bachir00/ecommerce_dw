with source as (
    select * from {{ source('ecommerce', 'products') }}
),

renamed as (
    select
        product_id,
        product_name,
        category,
        brand,
        price,
        cost
    from source
)

select * from renamed
