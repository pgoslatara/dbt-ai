{{
    config(
        materialized='incremental',
        unique_key=['station_id', 'city', 'metric_date'],
        incremental_strategy='merge'
    )
}}

WITH

trips AS (
    SELECT * FROM {{ ref('int_trips_unioned') }}
    {% if is_incremental() %}
        WHERE CAST(started_at AS DATE) > (SELECT MAX(metric_date) FROM {{ this }})
    {% endif %}
),

daily_metrics AS (
    SELECT
        start_station_id AS station_id,
        ROUND(AVG(duration_minutes), 2) AS avg_trip_duration_minutes,
        city,
        CAST(started_at AS DATE) AS metric_date,
        CAST(COUNT(*) AS INT64) AS total_trips
    FROM trips
    GROUP BY start_station_id, city, CAST(started_at AS DATE)
)

SELECT * FROM daily_metrics
