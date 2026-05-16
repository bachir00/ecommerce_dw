WITH source AS (
    SELECT * FROM {{ source('raw', 'order_items') }}
)

SELECT
    ORDER_ID                        AS order_id,
    ORDER_ITEM_ID                   AS order_item_id,
    PRODUCT_ID                      AS product_id,
    SELLER_ID                       AS seller_id,
    SHIPPING_LIMIT_DATE             AS shipping_limit_date,
    PRICE                           AS price,
    FREIGHT_VALUE                   AS freight_value,
    PRICE + FREIGHT_VALUE           AS total_item_value
FROM source