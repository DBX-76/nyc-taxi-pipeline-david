-- Load taxi zones reference data
-- Etape préalable: mettre le fichier taxi_zones.csv dans le stage

CREATE OR REPLACE STAGE NYC_TAXI.RAW.TAXI_ZONES_STAGE
  FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  );

-- Charger les zones depuis le stage
COPY INTO NYC_TAXI.RAW.TAXI_ZONES
FROM @NYC_TAXI.RAW.TAXI_ZONES_STAGE
FILE_FORMAT = (
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);
