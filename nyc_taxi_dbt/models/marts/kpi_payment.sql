{{ config(materialized='table') }}

select
    payment_type,
    case payment_type
        when 1 then 'Carte de crédit'
        when 2 then 'Espèces'
        when 3 then 'Pas de charge'
        when 4 then 'Litige'
        when 5 then 'Inconnu'
        else 'Autre'
    end as payment_label,
    count(*) as nb_courses,
    round(count(*) * 100.0 / sum(count(*)) over(), 2) as pct_total,
    round(avg(total_amount), 2) as total_moyen
from {{ ref('stg_yellow_trips') }}
group by payment_type
order by nb_courses desc