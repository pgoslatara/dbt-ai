-- Data Quality Checks for dbt-ai
-- Run against production BigQuery datasets to detect anomalies
-- 1. Daily trip counts for the past 7 days vs prior 30-day average
select
    'trip_volume' as check_name,
    city,
    metric_date,
    total_trips as current_value,
    avg_30d as baseline_value,
    round((total_trips - avg_30d) / nullif(stddev_30d, 0), 2) as z_score
from
    (
        select
            city,
            metric_date,
            total_trips,
            avg(total_trips) over (
                partition by city order by metric_date rows between 37 preceding and 8 preceding
            ) as avg_30d,
            stddev(total_trips) over (
                partition by city order by metric_date rows between 37 preceding and 8 preceding
            ) as stddev_30d
        from `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
        where metric_date >= date_sub(current_date(), interval 45 day)
        group by city, metric_date, total_trips
    )
where
    metric_date >= date_sub(current_date(), interval 7 day) and abs((total_trips - avg_30d) / nullif(stddev_30d, 0)) > 2
order by city, metric_date
;

-- 2. Average trip duration anomalies by city (past 7 days vs 30-day baseline)
select
    'duration_anomaly' as check_name,
    city,
    metric_date,
    avg_trip_duration_minutes as current_value,
    avg_30d_duration as baseline_value,
    round((avg_trip_duration_minutes - avg_30d_duration) / nullif(stddev_30d_duration, 0), 2) as z_score
from
    (
        select
            city,
            metric_date,
            avg_trip_duration_minutes,
            avg(avg_trip_duration_minutes) over (
                partition by city order by metric_date rows between 37 preceding and 8 preceding
            ) as avg_30d_duration,
            stddev(avg_trip_duration_minutes) over (
                partition by city order by metric_date rows between 37 preceding and 8 preceding
            ) as stddev_30d_duration
        from `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
        where metric_date >= date_sub(current_date(), interval 45 day)
    )
where
    metric_date >= date_sub(current_date(), interval 7 day)
    and abs((avg_trip_duration_minutes - avg_30d_duration) / nullif(stddev_30d_duration, 0)) > 2
order by city, metric_date
;

-- 3. Data freshness check — most recent data per city
select
    'data_freshness' as check_name,
    city,
    max(metric_date) as latest_date,
    date_diff(current_date(), max(metric_date), day) as days_stale
from `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
group by city
having date_diff(current_date(), max(metric_date), day) > 3
;

-- 4. Station count changes (new or disappeared stations)
select
    'station_change' as check_name,
    city,
    count(*) as current_station_count,
    (
        select count(*)
        from `{project_id}.dbt_ai_prod.dim_stations` as prev
        where prev.city = s.city and prev.total_trips > 0
    ) as active_station_count,
    count(*) - (
        select count(*)
        from `{project_id}.dbt_ai_prod.dim_stations` as prev
        where prev.city = s.city and prev.total_trips > 0
    ) as station_diff
from `{project_id}.dbt_ai_prod.dim_stations` as s
group by city
having
    abs(
        count(*) - (
            select count(*)
            from `{project_id}.dbt_ai_prod.dim_stations` as prev
            where prev.city = s.city and prev.total_trips > 0
        )
    )
    > 0
;
