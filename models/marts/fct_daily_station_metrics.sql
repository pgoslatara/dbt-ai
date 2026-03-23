{{
    config(
        materialized="incremental",
        incremental_strategy="merge",
        on_schema_change="fail",
        unique_key=["station_id", "city", "metric_date"],
    )
}}

with

    trips as (
        select *
        from {{ ref("int_trips_unioned") }}
        {% if is_incremental() %} where cast(started_at as date) > (select max(metric_date) from {{ this }}) {% endif %}
    ),

    daily_metrics as (
        select
            start_station_id as station_id,
            round(avg(duration_minutes), 2) as avg_trip_duration_minutes,
            city,
            cast(started_at as date) as metric_date,
            cast(count(*) as int64) as total_trips
        from trips
        group by start_station_id, city, cast(started_at as date)
    )

select *
from daily_metrics
