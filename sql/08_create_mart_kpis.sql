-- Create MART tables with aggregated KPIs
-- Transforme les données STAGING en métriques métier prêtes pour reporting
-- 4 vues agrégées pour analyse mensuelle, horaire, géographique et paiement

-- 1. KPIs globaux par mois
CREATE OR REPLACE TABLE NYC_TAXI.MART.KPI_MONTHLY AS
SELECT
    pickup_year,
    pickup_month,
    COUNT(*)                                    AS nb_courses,
    ROUND(AVG(trip_distance), 2)                AS distance_moyenne_km,
    ROUND(AVG(trip_duration_min), 2)            AS duree_moyenne_min,
    ROUND(AVG(fare_amount), 2)                  AS tarif_moyen,
    ROUND(AVG(total_amount), 2)                 AS total_moyen,
    ROUND(AVG(tip_percentage), 2)               AS pourboire_moyen_pct,
    ROUND(SUM(total_amount), 2)                 AS revenu_total,
    ROUND(SUM(tip_amount), 2)                   AS pourboires_total
FROM NYC_TAXI.STAGING.STG_TRIPS
GROUP BY pickup_year, pickup_month
ORDER BY pickup_year, pickup_month;

-- 2. KPIs par heure de la journée
-- Analyser les patterns de trafic et revenus par heure
CREATE OR REPLACE TABLE NYC_TAXI.MART.KPI_HOURLY AS
SELECT
    pickup_hour,
    COUNT(*)                                    AS nb_courses,
    ROUND(AVG(trip_distance), 2)                AS distance_moyenne,
    ROUND(AVG(total_amount), 2)                 AS total_moyen,
    ROUND(AVG(tip_percentage), 2)               AS pourboire_moyen_pct
FROM NYC_TAXI.STAGING.STG_TRIPS
GROUP BY pickup_hour
ORDER BY pickup_hour;

-- 3. KPIs par zone de pickup (top 20)
-- Identifier les zones les plus actives et lucratives
CREATE OR REPLACE TABLE NYC_TAXI.MART.KPI_ZONES AS
SELECT
    t.PULocationID,
    z.Borough,
    z.Zone,
    COUNT(*)                                    AS nb_courses,
    ROUND(AVG(t.total_amount), 2)               AS total_moyen,
    ROUND(AVG(t.trip_distance), 2)              AS distance_moyenne,
    ROUND(SUM(t.total_amount), 2)               AS revenu_total
FROM NYC_TAXI.STAGING.STG_TRIPS t
LEFT JOIN NYC_TAXI.RAW.TAXI_ZONES z 
    ON t.PULocationID = z.LocationID
GROUP BY t.PULocationID, z.Borough, z.Zone
ORDER BY nb_courses DESC
LIMIT 20;

-- 4. KPIs par type de paiement
-- Analyser les préférences et comportements de paiement
CREATE OR REPLACE TABLE NYC_TAXI.MART.KPI_PAYMENT AS
SELECT
    payment_type,
    CASE payment_type
        WHEN 1 THEN 'Carte de crédit'
        WHEN 2 THEN 'Espèces'
        WHEN 3 THEN 'Pas de charge'
        WHEN 4 THEN 'Litige'
        WHEN 5 THEN 'Inconnu'
    END                                         AS payment_label,
    COUNT(*)                                    AS nb_courses,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) 
        OVER(), 2)                              AS pct_total,
    ROUND(AVG(total_amount), 2)                 AS total_moyen
FROM NYC_TAXI.STAGING.STG_TRIPS
GROUP BY payment_type
ORDER BY nb_courses DESC;
