{{ config(materialized='table') }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('int_customers') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key
    ,customer_id
    ,email_address
FROM source_data