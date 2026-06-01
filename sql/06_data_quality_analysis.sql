-- Data quality analysis for NYC Taxi Yellow Trips
-- Vérifier la complétude, validité et cohérence des données chargées

USE DATABASE NYC_TAXI;
USE SCHEMA RAW;
USE WAREHOUSE NYC_TAXI_WH;

-- 1. Vue globale - comptage total
SELECT COUNT(*) AS total_lignes 
FROM YELLOW_TRIPS;

-- 2. Valeurs NULL par colonne critique
-- Identifier les données manquantes
SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN VendorID IS NULL THEN 1 ELSE 0 END)             AS null_vendor,
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END)      AS null_passengers,
    SUM(CASE WHEN trip_distance IS NULL THEN 1 ELSE 0 END)        AS null_distance,
    SUM(CASE WHEN PULocationID IS NULL THEN 1 ELSE 0 END)         AS null_pickup,
    SUM(CASE WHEN DOLocationID IS NULL THEN 1 ELSE 0 END)         AS null_dropoff,
    SUM(CASE WHEN fare_amount IS NULL THEN 1 ELSE 0 END)          AS null_fare,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END)         AS null_total
FROM YELLOW_TRIPS;

-- 3. Valeurs négatives ou aberrantes
-- Détecter les anomalies logiques
SELECT
    SUM(CASE WHEN trip_distance <= 0 THEN 1 ELSE 0 END)          AS distance_nulle_negative,
    SUM(CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END)             AS fare_negative,
    SUM(CASE WHEN total_amount < 0 THEN 1 ELSE 0 END)            AS total_negatif,
    SUM(CASE WHEN passenger_count <= 0 THEN 1 ELSE 0 END)        AS passagers_zero,
    SUM(CASE WHEN passenger_count > 6 THEN 1 ELSE 0 END)         AS passagers_aberrants
FROM YELLOW_TRIPS;

-- 4. Durées aberrantes
-- Vérifier la cohérence pickup/dropoff
SELECT
    SUM(CASE WHEN tpep_dropoff_datetime <= tpep_pickup_datetime 
        THEN 1 ELSE 0 END)                                        AS duree_negative,
    SUM(CASE WHEN DATEDIFF('hour', tpep_pickup_datetime, 
        tpep_dropoff_datetime) > 24 THEN 1 ELSE 0 END)           AS duree_plus_24h
FROM YELLOW_TRIPS;

-- 5. Types de paiement présents
-- Distribution des modes de paiement
SELECT payment_type, COUNT(*) AS nb
FROM YELLOW_TRIPS
GROUP BY payment_type
ORDER BY nb DESC;
