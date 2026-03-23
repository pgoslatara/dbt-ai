with

    source as (select * from {{ source("new_york_citibike", "citibike_trips") }}),

    renamed as (
        select
            cast(bikeid as string) as bike_id,
            'new_york' as city,
            round(tripduration / 60, 2) as duration_minutes,
            cast(end_station_id as string) as end_station_id,
            cast(stoptime as timestamp) as ended_at,
            cast(start_station_id as string) as start_station_id,
            cast(starttime as timestamp) as started_at,
            {{ dbt_utils.generate_surrogate_key(["bikeid", "starttime", "start_station_id"]) }} as trip_id,
            usertype as user_type
        from source
    )

select *
from renamed
