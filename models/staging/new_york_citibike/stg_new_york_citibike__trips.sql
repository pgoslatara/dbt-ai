WITH

source AS (
    SELECT *
    FROM {{ source('new_york_citibike', 'citibike_trips') }}
),

renamed AS (
    SELECT
        CAST(bikeid AS STRING) AS bike_id,
        'new_york' AS city,
        ROUND(tripduration / 60, 2) AS duration_minutes,
        CAST(end_station_id AS STRING) AS end_station_id,
        stoptime AS ended_at,
        CAST(start_station_id AS STRING) AS start_station_id,
        starttime AS started_at,
        {{ dbt_utils.generate_surrogate_key(['bikeid', 'starttime', 'start_station_id']) }} AS trip_id,
        usertype AS user_type
    FROM source
)

SELECT * FROM renamed
