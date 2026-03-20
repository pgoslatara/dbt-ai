-- Ensure all trips have a positive duration
SELECT
    trip_id,
    trip_duration_minutes
FROM {{ ref('fct_trips') }}
WHERE trip_duration_minutes <= 0
