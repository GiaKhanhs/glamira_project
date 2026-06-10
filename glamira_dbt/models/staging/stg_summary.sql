{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ source('raw', 'summary_raw') }}

)

,renamed_columns AS (

    SELECT
        _id AS event_id
        ,api_version
        ,cart_products
        ,cat_id AS category_id
        ,collect_id
        ,collection
        ,currency AS currency_code
        ,current_url
        ,device_id
        ,email_address
        ,ip
        ,is_paypal
        ,key_search
        ,local_time
        ,option AS option_json
        ,option_Kollektion AS option_kollektion_name
        ,option_alloy AS alloy_value_id
        ,`option_category id` AS option_category_id
        ,option_diamond AS diamond_value_id
        ,option_finish AS finish_value_id
        ,option_kollektion_id AS kollektion_id
        ,option_pearlcolor AS pearl_color_value_id
        ,option_price
        ,option_shapediamond AS shape_diamond_value_id
        ,option_stone AS stone_value_id
        ,order_id
        ,price AS product_price
        ,product_id
        ,recommendation
        ,recommendation_clicked_position
        ,recommendation_product_id
        ,recommendation_product_position
        ,referrer_url
        ,resolution
        ,show_recommendation
        ,store_id
        ,time_stamp
        ,user_agent
        ,user_id_db AS customer_id
        ,utm_medium
        ,utm_source
        ,viewing_product_id
    FROM source_data

)

,casted_columns AS (

    SELECT
        event_id
        ,api_version
        ,cart_products
        ,SAFE_CAST(category_id AS INT64) AS category_id
        ,collect_id
        ,collection
        ,LOWER(TRIM(currency_code)) AS currency_code
        ,current_url
        ,device_id
        ,email_address
        ,ip
        ,SAFE_CAST(is_paypal AS BOOL) AS is_paypal
        ,key_search
        ,local_time
        ,option_json
        ,option_kollektion_name
        ,alloy_value_id
        ,SAFE_CAST(option_category_id AS INT64) AS option_category_id
        ,diamond_value_id
        ,finish_value_id
        ,kollektion_id
        ,pearl_color_value_id
        ,SAFE_CAST(option_price AS NUMERIC) AS option_price
        ,shape_diamond_value_id
        ,stone_value_id
        ,order_id
        ,SAFE_CAST(product_price AS NUMERIC) AS product_price
        ,product_id
        ,recommendation
        ,SAFE_CAST(recommendation_clicked_position AS INT64) AS recommendation_clicked_position
        ,recommendation_product_id
        ,SAFE_CAST(recommendation_product_position AS INT64) AS recommendation_product_position
        ,referrer_url
        ,resolution
        ,SAFE_CAST(show_recommendation AS BOOL) AS show_recommendation
        ,SAFE_CAST(store_id AS INT64) AS store_id
        ,SAFE_CAST(time_stamp AS INT64) AS event_timestamp_unix
        ,TIMESTAMP_SECONDS(SAFE_CAST(time_stamp AS INT64)) AS event_timestamp
        ,DATE(TIMESTAMP_SECONDS(SAFE_CAST(time_stamp AS INT64))) AS event_date
        ,user_agent
        ,customer_id
        ,utm_medium
        ,utm_source
        ,viewing_product_id
    FROM renamed_columns

)

,deduplicated AS (

    SELECT * EXCEPT(rn)
    FROM (
        SELECT
            *
            ,ROW_NUMBER() OVER (
                PARTITION BY event_id
                ORDER BY event_id
            ) AS rn
        FROM casted_columns
    )
    WHERE rn = 1

)

SELECT *
FROM deduplicated