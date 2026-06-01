-- Setup warehouse and database for NYC Taxi project
-- Initialisation de l'environnement Snowflake principal

CREATE WAREHOUSE IF NOT EXISTS NYC_TAXI_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND   = 300
  AUTO_RESUME    = TRUE;

CREATE DATABASE IF NOT EXISTS NYC_TAXI;
