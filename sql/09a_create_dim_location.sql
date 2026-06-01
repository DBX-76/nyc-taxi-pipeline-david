-- Create dimension table for locations with SCD Type 2
-- Gère l'historique des changements de zones avec validité temporelle
-- SCD Type 2: conserve l'historique complet des modifications

CREATE OR REPLACE TABLE NYC_TAXI.STAGING.DIM_LOCATION (
    location_key        NUMBER AUTOINCREMENT PRIMARY KEY,  -- Clé surrogate
    location_id         NUMBER NOT NULL,                   -- Clé naturelle TLC
    borough             VARCHAR(50),
    zone                VARCHAR(100),
    service_zone        VARCHAR(50),
    -- Colonnes SCD Type 2 pour gestion d'historique
    valid_from          TIMESTAMP_NTZ NOT NULL,
    valid_to            TIMESTAMP_NTZ,                     -- NULL = enregistrement actif
    is_current          BOOLEAN NOT NULL DEFAULT TRUE
);