{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

)

,selected_columns AS (

    SELECT
        customer_id
        ,email_address
        ,event_timestamp
    FROM source_data
    WHERE customer_id IS NOT NULL

)

,deduplicated AS (

    SELECT * EXCEPT(row_number)
    FROM (
        SELECT
            *
            ,ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY event_timestamp DESC
            ) AS row_number
        FROM selected_columns
    )
    WHERE row_number = 1

)

SELECT *
FROM deduplicated