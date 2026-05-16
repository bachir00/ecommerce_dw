WITH source AS (
    SELECT * FROM {{ source('raw', 'reviews') }}
)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date::DATE    AS review_creation_date,
    review_answer_timestamp::DATE AS review_answer_date,
    CASE
        WHEN review_score >= 4 THEN 'positive'
        WHEN review_score = 3  THEN 'neutral'
        ELSE 'negative'
    END                           AS sentiment
FROM source