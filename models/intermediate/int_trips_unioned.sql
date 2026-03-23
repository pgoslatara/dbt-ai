with

    austin_trips as (
        select trip_id, city, duration_minutes, end_station_id, ended_at, start_station_id, started_at
        from {{ ref("stg_austin_bikeshare__trips") }}
    ),

    nyc_trips as (
        select trip_id, city, duration_minutes, end_station_id, ended_at, start_station_id, started_at
        from {{ ref("stg_new_york_citibike__trips") }}
    ),

    unioned as (
        select *
        from austin_trips
        union all
        select *
        from nyc_trips
    )

select *
from unioned
