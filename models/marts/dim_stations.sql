WITH

stations AS (
    SELECT * FROM {{ ref('int_stations_unioned') }}
),

trip_metrics AS (
    SELECT * FROM {{ ref('int_trip_metrics_by_station') }}
),

final AS (
    SELECT
        s.station_id,
        COALESCE(tm.avg_trip_duration_minutes, 0) AS avg_trip_duration_minutes,
        s.city,
        s.latitude,
        s.longitude,
        s.station_name,
        COALESCE(tm.total_trips, 0) AS total_trips
    FROM stations AS s
    LEFT JOIN trip_metrics AS tm
        ON s.station_id = tm.station_id
        AND s.city = tm.city
)

SELECT * FROM final
