with

    austin_stations as (
        select station_id, city, latitude, longitude, station_name from {{ ref("stg_austin_bikeshare__stations") }}
    ),

    nyc_stations as (
        select station_id, city, latitude, longitude, station_name from {{ ref("stg_new_york_citibike__stations") }}
    ),

    unioned as (
        select *
        from austin_stations
        union all
        select *
        from nyc_stations
    ),

    city_metadata as (select * from {{ ref("city_metadata") }}),

    enriched as (
        select u.station_id, u.city, cm.city_full_name, u.latitude, u.longitude, u.station_name, cm.timezone
        from unioned as u
        left join city_metadata as cm on u.city = cm.city
    )

select *
from enriched
