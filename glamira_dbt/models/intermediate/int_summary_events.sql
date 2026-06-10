{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

)

,selected_columns AS (

    SELECT
        event_id
        ,event_timestamp_unix
        ,event_timestamp
        ,event_date
        ,customer_id
        ,email_address
        ,device_id
        ,ip
        ,user_agent
        ,resolution
        ,product_id
        ,viewing_product_id
        ,recommendation_product_id
        ,category_id
        ,store_id
        ,order_id
        ,collect_id
        ,cart_products
        ,product_price
        ,option_price
        ,currency_code
        ,is_paypal
        ,show_recommendation
        ,recommendation
        ,recommendation_clicked_position
        ,recommendation_product_position
        ,current_url
        ,referrer_url
        ,utm_source
        ,utm_medium
        ,key_search
        ,api_version
        ,collection
        ,local_time
    FROM source_data

)

SELECT *
FROM selected_columns