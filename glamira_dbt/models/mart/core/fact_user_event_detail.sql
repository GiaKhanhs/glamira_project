{{ config(materialized='table') }}

WITH events AS (

    SELECT *
    FROM {{ ref('int_summary_events') }}

)

,date_dim AS (

    SELECT *
    FROM {{ ref('dim_date') }}

)

,customer_dim AS (

    SELECT *
    FROM {{ ref('dim_customer') }}

)

,product_dim AS (

    SELECT *
    FROM {{ ref('dim_product') }}

)

,device_dim AS (

    SELECT *
    FROM {{ ref('dim_device') }}

)

,traffic_source_dim AS (

    SELECT *
    FROM {{ ref('dim_traffic_source') }}

)

SELECT
    events.event_id
    ,date_dim.date_key
    ,customer_dim.customer_key
    ,product_dim.product_key
    ,device_dim.device_key
    ,traffic_source_dim.traffic_source_key

    ,events.event_timestamp
    ,events.event_date

    ,events.order_id
    ,events.collect_id
    ,events.cart_products

    ,events.recommendation
    ,events.recommendation_clicked_position
    ,events.recommendation_product_position

    ,events.product_price
    ,events.option_price

    ,events.is_paypal
    ,events.show_recommendation

    ,events.key_search
    ,events.api_version
    ,events.collection
    ,events.local_time
FROM events
LEFT JOIN date_dim
    ON events.event_date = date_dim.event_date
LEFT JOIN customer_dim
    ON events.customer_id = customer_dim.customer_id
LEFT JOIN product_dim
    ON events.product_id = product_dim.product_id
LEFT JOIN device_dim
    ON events.device_id = device_dim.device_id
LEFT JOIN traffic_source_dim
    ON events.utm_source = traffic_source_dim.utm_source
    AND events.utm_medium = traffic_source_dim.utm_medium
    AND events.referrer_url = traffic_source_dim.referrer_url
    AND events.current_url = traffic_source_dim.current_url