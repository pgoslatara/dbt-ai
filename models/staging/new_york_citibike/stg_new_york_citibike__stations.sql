WITH

source AS (
    SELECT *
    FROM {{ source('new_york_citibike', 'citibike_stations') }}
),

renamed AS (
    SELECT
        CAST(station_id AS STRING) AS station_id,
        capacity,
        'new_york' AS city,
        latitude,
        longitude,
        name AS station_name
    FROM source
)

SELECT * FROM renamed
