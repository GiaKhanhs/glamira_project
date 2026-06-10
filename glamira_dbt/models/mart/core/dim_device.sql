{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('int_devices') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['device_id']) }} AS device_key
    ,device_id
    ,ip
    ,user_agent
    ,resolution
FROM source_data