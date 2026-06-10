{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

)

,selected_columns AS (

    SELECT
        device_id
        ,ip
        ,user_agent
        ,resolution
        ,event_timestamp
    FROM source_data
    WHERE device_id IS NOT NULL

)

,deduplicated AS (

    SELECT * EXCEPT(row_number)
    FROM (
        SELECT
            *
            ,ROW_NUMBER() OVER (
                PARTITION BY device_id
                ORDER BY event_timestamp DESC
            ) AS row_number
        FROM selected_columns
    )
    WHERE row_number = 1

)

SELECT *
FROM deduplicated