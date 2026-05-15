with source as (
    select * from {{ source('ecommerce', 'reviews') }}
),

renamed as (
    select
        review_id,
        order_id,
        product_id,
        customer_id,
        rating,
        review_text,
        reviewed_at::timestamp as reviewed_at
    from source
)

select * from renamed
