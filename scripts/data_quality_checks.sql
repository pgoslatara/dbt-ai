-- Data Quality Checks for dbt-ai
-- Run against production BigQuery datasets to detect anomalies

-- 1. Daily trip counts for the past 7 days vs prior 30-day average
SELECT
    'trip_volume' AS check_name,
    city,
    metric_date,
    total_trips AS current_value,
    avg_30d AS baseline_value,
    ROUND((total_trips - avg_30d) / NULLIF(stddev_30d, 0), 2) AS z_score
FROM (
    SELECT
        city,
        metric_date,
        total_trips,
        AVG(total_trips) OVER (
            PARTITION BY city
            ORDER BY metric_date
            ROWS BETWEEN 37 PRECEDING AND 8 PRECEDING
        ) AS avg_30d,
        STDDEV(total_trips) OVER (
            PARTITION BY city
            ORDER BY metric_date
            ROWS BETWEEN 37 PRECEDING AND 8 PRECEDING
        ) AS stddev_30d
    FROM `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
    WHERE metric_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 45 DAY)
    GROUP BY city, metric_date, total_trips
)
WHERE metric_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
    AND ABS((total_trips - avg_30d) / NULLIF(stddev_30d, 0)) > 2
ORDER BY city, metric_date;

-- 2. Average trip duration anomalies by city (past 7 days vs 30-day baseline)
SELECT
    'duration_anomaly' AS check_name,
    city,
    metric_date,
    avg_trip_duration_minutes AS current_value,
    avg_30d_duration AS baseline_value,
    ROUND((avg_trip_duration_minutes - avg_30d_duration) / NULLIF(stddev_30d_duration, 0), 2) AS z_score
FROM (
    SELECT
        city,
        metric_date,
        avg_trip_duration_minutes,
        AVG(avg_trip_duration_minutes) OVER (
            PARTITION BY city
            ORDER BY metric_date
            ROWS BETWEEN 37 PRECEDING AND 8 PRECEDING
        ) AS avg_30d_duration,
        STDDEV(avg_trip_duration_minutes) OVER (
            PARTITION BY city
            ORDER BY metric_date
            ROWS BETWEEN 37 PRECEDING AND 8 PRECEDING
        ) AS stddev_30d_duration
    FROM `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
    WHERE metric_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 45 DAY)
)
WHERE metric_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
    AND ABS((avg_trip_duration_minutes - avg_30d_duration) / NULLIF(stddev_30d_duration, 0)) > 2
ORDER BY city, metric_date;

-- 3. Data freshness check — most recent data per city
SELECT
    'data_freshness' AS check_name,
    city,
    MAX(metric_date) AS latest_date,
    DATE_DIFF(CURRENT_DATE(), MAX(metric_date), DAY) AS days_stale
FROM `{project_id}.dbt_ai_prod.fct_daily_station_metrics`
GROUP BY city
HAVING DATE_DIFF(CURRENT_DATE(), MAX(metric_date), DAY) > 3;

-- 4. Station count changes (new or disappeared stations)
SELECT
    'station_change' AS check_name,
    city,
    COUNT(*) AS current_station_count,
    (SELECT COUNT(*) FROM `{project_id}.dbt_ai_prod.dim_stations` AS prev WHERE prev.city = s.city AND prev.total_trips > 0) AS active_station_count,
    COUNT(*) - (SELECT COUNT(*) FROM `{project_id}.dbt_ai_prod.dim_stations` AS prev WHERE prev.city = s.city AND prev.total_trips > 0) AS station_diff
FROM `{project_id}.dbt_ai_prod.dim_stations` AS s
GROUP BY city
HAVING ABS(COUNT(*) - (SELECT COUNT(*) FROM `{project_id}.dbt_ai_prod.dim_stations` AS prev WHERE prev.city = s.city AND prev.total_trips > 0)) > 0;
