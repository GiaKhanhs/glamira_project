{{ config(materialized='table') }}

WITH checkout_success_events AS (

    SELECT
        event_id
        ,order_id
        ,event_timestamp
        ,event_date
        ,customer_id
        ,device_id
        ,utm_source
        ,utm_medium
        ,referrer_url
        ,current_url
        ,is_paypal
        ,cart_products
    FROM {{ ref('int_summary_events') }}
    WHERE collection = 'checkout_success'
        AND cart_products IS NOT NULL
        AND cart_products != ''

)

,cart_items AS (

    SELECT
        checkout_success_events.event_id
        ,checkout_success_events.order_id
        ,checkout_success_events.event_timestamp
        ,checkout_success_events.event_date
        ,checkout_success_events.customer_id
        ,checkout_success_events.device_id
        ,checkout_success_events.utm_source
        ,checkout_success_events.utm_medium
        ,checkout_success_events.referrer_url
        ,checkout_success_events.current_url
        ,checkout_success_events.is_paypal

        ,cart_item
    FROM checkout_success_events
    CROSS JOIN UNNEST(JSON_QUERY_ARRAY(cart_products)) AS cart_item

)

,parsed_cart_items AS (

    SELECT
        event_id
        ,order_id
        ,event_timestamp
        ,event_date
        ,customer_id
        ,device_id
        ,utm_source
        ,utm_medium
        ,referrer_url
        ,current_url
        ,is_paypal

        ,CAST(JSON_VALUE(cart_item, '$.product_id') AS STRING) AS product_id
        ,SAFE_CAST(JSON_VALUE(cart_item, '$.amount') AS INT64) AS order_qty
        ,JSON_VALUE(cart_item, '$.currency') AS currency_code

        ,SAFE_CAST(
            REPLACE(JSON_VALUE(cart_item, '$.price'), ',', '.') AS NUMERIC
        ) AS unit_price

        ,JSON_QUERY(cart_item, '$.option') AS product_option_json
    FROM cart_items

)

,calculated_measures AS (

    SELECT
        event_id
        ,order_id
        ,event_timestamp
        ,event_date
        ,customer_id
        ,device_id
        ,utm_source
        ,utm_medium
        ,referrer_url
        ,current_url
        ,is_paypal
        ,product_id
        ,order_qty
        ,currency_code
        ,unit_price
        ,unit_price * order_qty AS sales_amount
        ,unit_price IS NULL AS has_missing_unit_price
        ,order_qty IS NULL AS has_missing_order_qty
        ,product_option_json
    FROM parsed_cart_items

)

,enriched_with_dimensions AS (

    SELECT
        calculated_measures.event_id
        ,calculated_measures.order_id

        ,dim_date.date_key
        ,dim_customer.customer_key
        ,dim_product.product_key
        ,dim_device.device_key
        ,dim_traffic_source.traffic_source_key

        ,calculated_measures.event_timestamp
        ,calculated_measures.event_date

        ,calculated_measures.product_id
        ,calculated_measures.order_qty
        ,calculated_measures.unit_price
        ,calculated_measures.sales_amount
        ,calculated_measures.currency_code

        ,calculated_measures.is_paypal
        ,calculated_measures.has_missing_unit_price
        ,calculated_measures.has_missing_order_qty
        ,calculated_measures.product_option_json
    FROM calculated_measures
    LEFT JOIN {{ ref('dim_date') }} AS dim_date
        ON calculated_measures.event_date = dim_date.event_date
    LEFT JOIN {{ ref('dim_customer') }} AS dim_customer
        ON calculated_measures.customer_id = dim_customer.customer_id
    LEFT JOIN {{ ref('dim_product') }} AS dim_product
        ON calculated_measures.product_id = dim_product.product_id
    LEFT JOIN {{ ref('dim_device') }} AS dim_device
        ON calculated_measures.device_id = dim_device.device_id
    LEFT JOIN {{ ref('dim_traffic_source') }} AS dim_traffic_source
        ON calculated_measures.utm_source = dim_traffic_source.utm_source
        AND calculated_measures.utm_medium = dim_traffic_source.utm_medium
        AND calculated_measures.referrer_url = dim_traffic_source.referrer_url
        AND calculated_measures.current_url = dim_traffic_source.current_url

)

SELECT *
FROM enriched_with_dimensions