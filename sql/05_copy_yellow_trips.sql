-- Load Yellow Taxi trip data from stage
-- Utiliser TO_TIMESTAMP pour convertir les microsecondes Unix en timestamps
-- Puis nettoyer les dates hors plage 2024-2025

COPY INTO NYC_TAXI.RAW.YELLOW_TRIPS
FROM (
  SELECT
    $1:VendorID::NUMBER,
    TO_TIMESTAMP($1:tpep_pickup_datetime::NUMBER, 6),
    TO_TIMESTAMP($1:tpep_dropoff_datetime::NUMBER, 6),
    $1:passenger_count::NUMBER,
    $1:trip_distance::FLOAT,
    $1:RatecodeID::NUMBER,
    $1:store_and_fwd_flag::VARCHAR,
    $1:PULocationID::NUMBER,
    $1:DOLocationID::NUMBER,
    $1:payment_type::NUMBER,
    $1:fare_amount::FLOAT,
    $1:extra::FLOAT,
    $1:mta_tax::FLOAT,
    $1:tip_amount::FLOAT,
    $1:tolls_amount::FLOAT,
    $1:improvement_surcharge::FLOAT,
    $1:total_amount::FLOAT,
    $1:congestion_surcharge::FLOAT,
    $1:airport_fee::FLOAT
  FROM @NYC_TAXI.RAW.NYC_TAXI_STAGE
)
FILE_FORMAT = (TYPE = 'PARQUET')
PATTERN = '.*yellow.*\.parquet.*'
ON_ERROR = 'CONTINUE';

-- Nettoyer les dates corrompues (hors plage 2024-2025)
-- Supprimer les lignes avec timestamps invalides
DELETE FROM NYC_TAXI.RAW.YELLOW_TRIPS
WHERE tpep_pickup_datetime > '2025-12-31' OR tpep_pickup_datetime < '2024-01-01'
   OR tpep_dropoff_datetime > '2025-12-31' OR tpep_dropoff_datetime < '2024-01-01';

-- Validation - voir la plage de dates chargée
SELECT
  COUNT(*) AS total_trips,
  MIN(tpep_pickup_datetime) AS date_min,
  MAX(tpep_pickup_datetime) AS date_max
FROM NYC_TAXI.RAW.YELLOW_TRIPS;
