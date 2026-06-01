-- Create schemas for data layers
-- RAW: données brutes depuis source
-- STAGING: données transformées et nettoyées
-- MART: données agrégées pour reporting

CREATE SCHEMA IF NOT EXISTS NYC_TAXI.RAW;
CREATE SCHEMA IF NOT EXISTS NYC_TAXI.STAGING;
CREATE SCHEMA IF NOT EXISTS NYC_TAXI.MART;
