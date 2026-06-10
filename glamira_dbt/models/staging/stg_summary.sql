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
        NULLIF(TRIM(event_id), '') AS event_id
        ,NULLIF(TRIM(api_version), '') AS api_version
        ,NULLIF(TRIM(cart_products), '') AS cart_products
        ,SAFE_CAST(NULLIF(TRIM(category_id), '') AS INT64) AS category_id
        ,NULLIF(TRIM(collect_id), '') AS collect_id
        ,NULLIF(TRIM(collection), '') AS collection
        ,LOWER(NULLIF(TRIM(currency_code), '')) AS currency_code
        ,NULLIF(TRIM(current_url), '') AS current_url
        ,NULLIF(TRIM(device_id), '') AS device_id
        ,NULLIF(TRIM(email_address), '') AS email_address
        ,NULLIF(TRIM(ip), '') AS ip
        ,SAFE_CAST(NULLIF(TRIM(is_paypal), '') AS BOOL) AS is_paypal
        ,NULLIF(TRIM(key_search), '') AS key_search
        ,NULLIF(TRIM(local_time), '') AS local_time
        ,NULLIF(TRIM(option_json), '') AS option_json
        ,NULLIF(TRIM(option_kollektion_name), '') AS option_kollektion_name
        ,NULLIF(TRIM(alloy_value_id), '') AS alloy_value_id
        ,SAFE_CAST(NULLIF(TRIM(option_category_id), '') AS INT64) AS option_category_id
        ,NULLIF(TRIM(diamond_value_id), '') AS diamond_value_id
        ,NULLIF(TRIM(finish_value_id), '') AS finish_value_id
        ,NULLIF(TRIM(kollektion_id), '') AS kollektion_id
        ,NULLIF(TRIM(pearl_color_value_id), '') AS pearl_color_value_id
        ,SAFE_CAST(NULLIF(TRIM(option_price), '') AS NUMERIC) AS option_price
        ,NULLIF(TRIM(shape_diamond_value_id), '') AS shape_diamond_value_id
        ,NULLIF(TRIM(stone_value_id), '') AS stone_value_id
        ,NULLIF(TRIM(order_id), '') AS order_id
        ,SAFE_CAST(NULLIF(TRIM(product_price), '') AS NUMERIC) AS product_price
        ,NULLIF(TRIM(product_id), '') AS product_id
        ,NULLIF(TRIM(recommendation), '') AS recommendation
        ,SAFE_CAST(NULLIF(TRIM(recommendation_clicked_position), '') AS INT64) AS recommendation_clicked_position
        ,NULLIF(TRIM(recommendation_product_id), '') AS recommendation_product_id
        ,SAFE_CAST(NULLIF(TRIM(recommendation_product_position), '') AS INT64) AS recommendation_product_position
        ,NULLIF(TRIM(referrer_url), '') AS referrer_url
        ,NULLIF(TRIM(resolution), '') AS resolution
        ,SAFE_CAST(NULLIF(TRIM(show_recommendation), '') AS BOOL) AS show_recommendation
        ,SAFE_CAST(NULLIF(TRIM(store_id), '') AS INT64) AS store_id
        ,SAFE_CAST(NULLIF(TRIM(time_stamp), '') AS INT64) AS event_timestamp_unix
        ,TIMESTAMP_SECONDS(SAFE_CAST(NULLIF(TRIM(time_stamp), '') AS INT64)) AS event_timestamp
        ,DATE(TIMESTAMP_SECONDS(SAFE_CAST(NULLIF(TRIM(time_stamp), '') AS INT64))) AS event_date
        ,NULLIF(TRIM(user_agent), '') AS user_agent
        ,NULLIF(TRIM(customer_id), '') AS customer_id
        ,NULLIF(TRIM(utm_medium), '') AS utm_medium
        ,NULLIF(TRIM(utm_source), '') AS utm_source
        ,NULLIF(TRIM(viewing_product_id), '') AS viewing_product_id
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