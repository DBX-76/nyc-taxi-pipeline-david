-- Create staging table with data cleaning rules
-- Transforme les données RAW en données de qualité pour analyse
-- Applique les règles de nettoyage définies dans RAPPORT_QUALITE.md

CREATE OR REPLACE TABLE NYC_TAXI.STAGING.STG_TRIPS AS
SELECT
    -- Identifiants
    VendorID,
    
    -- Dates
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    
    -- Durée calculée en minutes
    DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_min,
    
    -- Passagers
    passenger_count,
    
    -- Distance
    trip_distance,
    
    -- Localisation
    PULocationID,
    DOLocationID,
    
    -- Paiement
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
    
    -- Colonne calculée : pourcentage pourboire
    CASE 
        WHEN fare_amount > 0 
        THEN ROUND((tip_amount / fare_amount) * 100, 2)
        ELSE 0 
    END AS tip_percentage,

    -- Colonne : tranche horaire de pickup
    HOUR(tpep_pickup_datetime) AS pickup_hour,
    
    -- Colonne : jour de la semaine
    DAYOFWEEK(tpep_pickup_datetime) AS pickup_dow,
    
    -- Colonne : mois
    MONTH(tpep_pickup_datetime) AS pickup_month,
    
    -- Colonne : année
    YEAR(tpep_pickup_datetime) AS pickup_year

FROM NYC_TAXI.RAW.YELLOW_TRIPS

-- Règles de nettoyage appliquées pour garantir la qualité
WHERE
    -- Exclure passenger_count NULL ou aberrant
    passenger_count IS NOT NULL
    AND passenger_count > 0
    AND passenger_count <= 6
    
    -- Exclure distances invalides
    AND trip_distance > 0
    
    -- Exclure montants négatifs
    AND fare_amount >= 0
    AND total_amount >= 0
    
    -- Exclure durées aberrantes
    AND tpep_dropoff_datetime > tpep_pickup_datetime
    AND DATEDIFF('hour', tpep_pickup_datetime, tpep_dropoff_datetime) <= 24
    
    -- Exclure payment_type inconnu (incomplete transactions)
    AND payment_type != 0;
