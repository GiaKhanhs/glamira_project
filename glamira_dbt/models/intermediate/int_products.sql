{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

)

,selected_columns AS (

    SELECT
        product_id
        ,category_id
        ,product_price
        ,currency_code
        ,alloy_value_id
        ,diamond_value_id
        ,finish_value_id
        ,stone_value_id
        ,pearl_color_value_id
        ,shape_diamond_value_id
        ,option_category_id
        ,kollektion_id
        ,event_timestamp
    FROM source_data
    WHERE product_id IS NOT NULL

)

,deduplicated AS (

    SELECT * EXCEPT(row_number)
    FROM (
        SELECT
            *
            ,ROW_NUMBER() OVER (
                PARTITION BY product_id
                ORDER BY event_timestamp DESC
            ) AS row_number
        FROM selected_columns
    )
    WHERE row_number = 1

)

SELECT *
FROM deduplicated