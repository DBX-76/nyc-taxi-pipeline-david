{{ config(materialized='table') }}

select
    t.PULocationID,
    z.Borough,
    z.Zone,
    count(*) as nb_courses,
    round(avg(t.total_amount), 2) as total_moyen,
    round(avg(t.trip_distance), 2) as distance_moyenne,
    round(sum(t.total_amount), 2) as revenu_total
from {{ ref('stg_yellow_trips') }} t
left join {{ source('raw_nyc_taxi', 'TAXI_ZONES') }} z
    on t.PULocationID = z.LocationID
group by t.PULocationID, z.Borough, z.Zone
order by nb_courses desc
limit 20