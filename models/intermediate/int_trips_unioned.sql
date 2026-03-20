WITH

austin_trips AS (
    SELECT
        trip_id,
        city,
        duration_minutes,
        end_station_id,
        ended_at,
        start_station_id,
        started_at
    FROM {{ ref('stg_austin_bikeshare__trips') }}
),

nyc_trips AS (
    SELECT
        trip_id,
        city,
        duration_minutes,
        end_station_id,
        ended_at,
        start_station_id,
        started_at
    FROM {{ ref('stg_new_york_citibike__trips') }}
),

unioned AS (
    SELECT * FROM austin_trips
    UNION ALL
    SELECT * FROM nyc_trips
)

SELECT * FROM unioned
