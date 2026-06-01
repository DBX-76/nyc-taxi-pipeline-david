-- Create raw data tables
-- YELLOW_TRIPS: données brutes des trajets Yellow Taxi
-- TAXI_ZONES: reference table pour les zones géographiques
-- NYC_TAXI_STAGE: stage pour les fichiers Parquet

CREATE OR REPLACE TABLE NYC_TAXI.RAW.YELLOW_TRIPS (
  VendorID              NUMBER,
  tpep_pickup_datetime  TIMESTAMP_NTZ,
  tpep_dropoff_datetime TIMESTAMP_NTZ,
  passenger_count       NUMBER,
  trip_distance         FLOAT,
  RatecodeID            NUMBER,
  store_and_fwd_flag    VARCHAR(1),
  PULocationID          NUMBER,
  DOLocationID          NUMBER,
  payment_type          NUMBER,
  fare_amount           FLOAT,
  extra                 FLOAT,
  mta_tax               FLOAT,
  tip_amount            FLOAT,
  tolls_amount          FLOAT,
  improvement_surcharge FLOAT,
  total_amount          FLOAT,
  congestion_surcharge  FLOAT,
  airport_fee           FLOAT
);

CREATE OR REPLACE TABLE NYC_TAXI.RAW.TAXI_ZONES (
  LocationID   NUMBER PRIMARY KEY,
  Borough      VARCHAR(50),
  Zone         VARCHAR(100),
  service_zone VARCHAR(50)
);

CREATE OR REPLACE STAGE NYC_TAXI.RAW.NYC_TAXI_STAGE
  FILE_FORMAT = (
    TYPE = 'PARQUET'
    SNAPPY_COMPRESSION = TRUE
  );
