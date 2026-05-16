WITH source AS (
    SELECT * FROM {{ source('raw', 'payments') }}
)

SELECT
    ORDER_ID                        AS order_id,
    PAYMENT_SEQUENTIAL              AS payment_sequential,
    PAYMENT_TYPE                    AS payment_type,
    PAYMENT_INSTALLMENTS            AS payment_installments,
    PAYMENT_VALUE                   AS payment_value
FROM source