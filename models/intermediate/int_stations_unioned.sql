WITH

austin_stations AS (
    SELECT
        station_id,
        city,
        latitude,
        longitude,
        station_name
    FROM {{ ref('stg_austin_bikeshare__stations') }}
),

nyc_stations AS (
    SELECT
        station_id,
        city,
        latitude,
        longitude,
        station_name
    FROM {{ ref('stg_new_york_citibike__stations') }}
),

unioned AS (
    SELECT * FROM austin_stations
    UNION ALL
    SELECT * FROM nyc_stations
)

SELECT * FROM unioned
