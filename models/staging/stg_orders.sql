WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

renamed AS (
    SELECT
        ORDER_ID                                        AS order_id,
        CUSTOMER_ID                                     AS customer_id,
        ORDER_STATUS                                    AS order_status,
        TRY_TO_DATE(ORDER_PURCHASE_TIMESTAMP)           AS order_date,
        TRY_TO_DATE(ORDER_APPROVED_AT)                  AS approved_date,
        TRY_TO_DATE(ORDER_DELIVERED_CARRIER_DATE)       AS carrier_date,
        TRY_TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE)      AS delivered_date,
        TRY_TO_DATE(ORDER_ESTIMATED_DELIVERY_DATE)      AS estimated_date,
        DATEDIFF('day',
            TRY_TO_DATE(ORDER_PURCHASE_TIMESTAMP),
            TRY_TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE)
        )                                               AS delivery_days,
        CASE
            WHEN TRY_TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE)
                <= TRY_TO_DATE(ORDER_ESTIMATED_DELIVERY_DATE)
            THEN TRUE
            ELSE FALSE
        END                                             AS delivered_on_time
    FROM source
    WHERE ORDER_STATUS != 'canceled'
)

SELECT * FROM renamed