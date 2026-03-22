with

    source as (select * from {{ source("austin_bikeshare", "bikeshare_stations") }}),

    renamed as (
        select
            cast(station_id as string) as station_id,
            'austin' as city,
            cast(regexp_extract(location, r'\(([^,]+),') as float64) as latitude,
            cast(regexp_extract(location, r', ([^)]+)\)') as float64) as longitude,
            name as station_name,
            status
        from source
    )

select *
from renamed
