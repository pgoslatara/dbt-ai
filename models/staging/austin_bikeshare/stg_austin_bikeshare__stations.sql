WITH

source AS (
    SELECT *
    FROM {{ source('austin_bikeshare', 'bikeshare_stations') }}
),

renamed AS (
    SELECT
        CAST(station_id AS STRING) AS station_id,
        'austin' AS city,
        latitude,
        longitude,
        name AS station_name,
        status,
        nonexistent_column AS broken_column
    FROM source
)

SELECT * FROM renamed
