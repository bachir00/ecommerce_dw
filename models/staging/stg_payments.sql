with source as (
    select * from {{ source('ecommerce', 'payments') }}
),

renamed as (
    select
        payment_id,
        order_id,
        payment_method,
        amount,
        status,
        paid_at::timestamp as paid_at
    from source
)

select * from renamed
