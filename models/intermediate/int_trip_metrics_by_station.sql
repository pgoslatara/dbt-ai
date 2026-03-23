with

    trips as (select * from {{ ref("int_trips_unioned") }}),

    metrics as (
        select
            start_station_id as station_id,
            city,
            count(*) as total_trips,
            round(avg(duration_minutes), 2) as avg_trip_duration_minutes
        from trips
        group by start_station_id, city
    )

select *
from metrics
