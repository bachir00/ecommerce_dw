with source as (
    select * from {{ source('ecommerce', 'orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        status,
        created_at::timestamp as ordered_at,
        updated_at::timestamp as updated_at
    from source
)

select * from renamed
