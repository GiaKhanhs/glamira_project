{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('int_traffic_sources') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'utm_source',
        'utm_medium',
        'referrer_url',
        'current_url'
    ]) }} AS traffic_source_key
    ,utm_source
    ,utm_medium
    ,referrer_url
    ,current_url
FROM source_data