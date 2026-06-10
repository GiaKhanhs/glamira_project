{{ config(materialized='table') }}

WITH source_data AS (

    SELECT DISTINCT
        event_date
    FROM {{ ref('int_summary_events') }}
    WHERE event_date IS NOT NULL

)

SELECT
    CAST(FORMAT_DATE('%Y%m%d', event_date) AS INT64) AS date_key
    ,event_date
    ,EXTRACT(YEAR FROM event_date) AS year
    ,EXTRACT(QUARTER FROM event_date) AS quarter
    ,EXTRACT(MONTH FROM event_date) AS month
    ,EXTRACT(WEEK FROM event_date) AS week_of_year
    ,EXTRACT(DAY FROM event_date) AS day
    ,FORMAT_DATE('%A', event_date) AS day_of_week
FROM source_data