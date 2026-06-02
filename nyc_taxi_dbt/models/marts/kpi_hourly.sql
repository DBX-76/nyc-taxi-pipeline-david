{{ config(materialized='table') }}

select
    pickup_hour,
    count(*) as nb_courses,
    round(avg(trip_distance), 2) as distance_moyenne,
    round(avg(total_amount), 2) as total_moyen,
    round(avg(tip_percentage), 2) as pourboire_moyen_pct
from {{ ref('stg_yellow_trips') }}
group by pickup_hour
order by pickup_hour