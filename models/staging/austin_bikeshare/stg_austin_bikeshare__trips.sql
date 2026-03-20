WITH

source AS (
    SELECT *
    FROM {{ source('austin_bikeshare', 'bikeshare_trips') }}
),

renamed AS (
    SELECT
        CAST(trip_id AS STRING) AS trip_id,
        'austin' AS city,
        duration_minutes,
        CAST(end_station_id AS STRING) AS end_station_id,
        end_time AS ended_at,
        CAST(start_station_id AS STRING) AS start_station_id,
        start_time AS started_at,
        subscriber_type
    FROM source
)

SELECT * FROM renamed
