WITH

source AS (
    SELECT *
    FROM {{ source('austin_bikeshare', 'bikeshare_stations') }}
),

renamed AS (
    SELECT
        CAST(station_id AS STRING) AS station_id,
        'austin' AS city,
        CAST(REGEXP_EXTRACT(location, r'\(([^,]+),') AS FLOAT64) AS latitude,
        CAST(REGEXP_EXTRACT(location, r', ([^)]+)\)') AS FLOAT64) AS longitude,
        name AS station_name,
        status
    FROM source
)

SELECT * FROM renamed
