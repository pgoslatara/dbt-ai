WITH

trips AS (
    SELECT * FROM {{ ref('int_trips_unioned') }}
),

metrics AS (
    SELECT
        start_station_id AS station_id,
        city,
        COUNT(*) AS total_trips,
        ROUND(AVG(duration_minutes), 2) AS avg_trip_duration_minutes
    FROM trips
    GROUP BY start_station_id, city
)

SELECT * FROM metrics
