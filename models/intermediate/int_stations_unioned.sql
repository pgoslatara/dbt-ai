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
),

city_metadata AS (
    SELECT * FROM {{ ref('city_metadata') }}
),

enriched AS (
    SELECT
        u.station_id,
        u.city,
        cm.city_full_name,
        u.latitude,
        u.longitude,
        u.station_name,
        cm.timezone
    FROM unioned AS u
    LEFT JOIN city_metadata AS cm
        ON u.city = cm.city
)

SELECT * FROM enriched
