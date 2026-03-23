with

    stations as (select * from {{ ref("int_stations_unioned") }}),

    trip_metrics as (select * from {{ ref("int_trip_metrics_by_station") }}),

    final as (
        select
            s.station_id,
            coalesce(tm.avg_trip_duration_minutes, 0) as avg_trip_duration_minutes,
            s.city,
            s.city_full_name,
            s.latitude,
            s.longitude,
            s.station_name,
            s.timezone,
            coalesce(tm.total_trips, 0) as total_trips
        from stations as s
        left join trip_metrics as tm on s.station_id = tm.station_id and s.city = tm.city
    )

select *
from final
