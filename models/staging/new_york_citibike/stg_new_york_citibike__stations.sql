with

    source as (select * from {{ source("new_york_citibike", "citibike_stations") }}),

    renamed as (
        select
            cast(station_id as string) as station_id,
            capacity,
            'new_york' as city,
            latitude,
            longitude,
            name as station_name
        from source
    )

select *
from renamed
