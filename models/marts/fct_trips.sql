WITH

trips AS (
    SELECT * FROM {{ ref('int_trips_unioned') }}
),

final AS (
    SELECT
        trip_id,
        city,
        EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
        end_station_id,
        ended_at,
        start_station_id = end_station_id AS is_round_trip,
        EXTRACT(DAYOFWEEK FROM started_at) IN (1, 7) AS is_weekend,
        start_station_id,
        started_at,
        duration_minutes AS trip_duration_minutes
    FROM trips
)

SELECT * FROM final
