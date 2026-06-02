{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_nyc_taxi', 'YELLOW_TRIPS') }}
),

renamed as (
    select
        VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        PULocationID,
        DOLocationID,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        airport_fee,
        -- Calculs ajoutés
        DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_min,
        CASE WHEN fare_amount > 0 THEN ROUND((tip_amount / fare_amount) * 100, 2) ELSE 0 END AS tip_percentage,
        HOUR(tpep_pickup_datetime) AS pickup_hour,
        DAYOFWEEK(tpep_pickup_datetime) AS pickup_dow,
        MONTH(tpep_pickup_datetime) AS pickup_month,
        YEAR(tpep_pickup_datetime) AS pickup_year
    from source
    where passenger_count IS NOT NULL
      and passenger_count > 0 
      and passenger_count <= 6
      and trip_distance > 0
      and fare_amount >= 0
      and total_amount >= 0
      and tpep_dropoff_datetime > tpep_pickup_datetime
      and datediff('hour', tpep_pickup_datetime, tpep_dropoff_datetime) <= 24
      and payment_type != 0
      -- Filtre sur les résidus corrompus identifiés au Sprint 2
      and not (pickup_year = 2025 and pickup_month in (2, 3))
)

select * from renamed