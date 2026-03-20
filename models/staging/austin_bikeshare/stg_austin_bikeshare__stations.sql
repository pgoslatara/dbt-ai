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
        status
    FROM source
)

SELECT * FROM renamed
