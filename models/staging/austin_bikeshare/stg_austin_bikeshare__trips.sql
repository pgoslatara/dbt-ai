WITH

source AS (
    SELECT *
    FROM {{ source('austin_bikeshare', 'bikeshare_trips') }}
),

renamed AS (
    SELECT
        CAST(trip_id AS STRING) AS trip_id,
        'austin' AS city,
        CAST(duration_minutes AS FLOAT64) AS duration_minutes,
        CAST(end_station_id AS STRING) AS end_station_id,
        TIMESTAMP_ADD(CAST(start_time AS TIMESTAMP), INTERVAL CAST(duration_minutes AS INT64) MINUTE) AS ended_at,
        CAST(start_station_id AS STRING) AS start_station_id,
        CAST(start_time AS TIMESTAMP) AS started_at,
        subscriber_type
    FROM source
)

SELECT * FROM renamed
