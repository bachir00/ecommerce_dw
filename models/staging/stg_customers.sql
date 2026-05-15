with source as (
    select * from {{ source('ecommerce', 'customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        country,
        created_at::timestamp as registered_at
    from source
)

select * from renamed
