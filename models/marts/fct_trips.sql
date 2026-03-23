with

    trips as (select * from {{ ref("int_trips_unioned") }}),

    final as (
        select
            trip_id,
            city,
            extract(dayofweek from started_at) as day_of_week,
            end_station_id,
            ended_at,
            start_station_id = end_station_id as is_round_trip,
            extract(dayofweek from started_at) in (1, 7) as is_weekend,
            start_station_id,
            started_at,
            duration_minutes as trip_duration_minutes
        from trips
    )

select *
from final
