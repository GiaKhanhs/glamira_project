{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

)

,selected_columns AS (

    SELECT
        utm_source
        ,utm_medium
        ,referrer_url
        ,current_url
    FROM source_data
    WHERE utm_source IS NOT NULL
        OR utm_medium IS NOT NULL
        OR referrer_url IS NOT NULL
        OR current_url IS NOT NULL

)

,deduplicated AS (

    SELECT DISTINCT
        utm_source
        ,utm_medium
        ,referrer_url
        ,current_url
    FROM selected_columns

)

SELECT *
FROM deduplicated