-- Load initial locations into dimension table
-- Charge les zones TLC comme enregistrements initiaux (actifs)
-- Marque tous les enregistrements comme version courante

INSERT INTO NYC_TAXI.STAGING.DIM_LOCATION (
    location_id,
    borough,
    zone,
    service_zone,
    valid_from,
    valid_to,
    is_current
)
SELECT
    LocationID,
    Borough,
    Zone,
    service_zone,
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
FROM NYC_TAXI.RAW.TAXI_ZONES;
