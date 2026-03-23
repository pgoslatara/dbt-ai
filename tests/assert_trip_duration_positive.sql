-- Ensure all trips have a positive duration
select trip_id, trip_duration_minutes from {{ ref("fct_trips") }} where trip_duration_minutes <= 0
