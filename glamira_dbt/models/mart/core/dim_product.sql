{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('int_products') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key
    ,product_id
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
FROM source_data