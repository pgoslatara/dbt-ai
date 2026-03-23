with

    source as (select * from {{ source("austin_bikeshare", "bikeshare_trips") }}),

    renamed as (
        select
            cast(trip_id as string) as trip_id,
            'austin' as city,
            cast(duration_minutes as float64) as duration_minutes,
            cast(end_station_id as string) as end_station_id,
            timestamp_add(
                cast(start_time as timestamp), interval cast(round(duration_minutes) as int64) minute
            ) as ended_at,
            cast(start_station_id as string) as start_station_id,
            cast(start_time as timestamp) as started_at,
            subscriber_type
        from source
    )

select *
from renamed
