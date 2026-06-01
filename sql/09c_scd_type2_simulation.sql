-- Demonstrate SCD Type 2 with zone change simulation
-- Montre comment gérer un changement d'attribut avec SCD Type 2
-- Exemple: changement service_zone pour JFK Airport

-- Étape A: fermer l'enregistrement actuel
UPDATE NYC_TAXI.STAGING.DIM_LOCATION
SET
    valid_to   = CURRENT_TIMESTAMP,
    is_current = FALSE
WHERE location_id = 132  -- JFK Airport
  AND is_current = TRUE;

-- Étape B: insérer le nouvel enregistrement
INSERT INTO NYC_TAXI.STAGING.DIM_LOCATION (
    location_id,
    borough,
    zone,
    service_zone,
    valid_from,
    valid_to,
    is_current
)
VALUES (
    132,
    'Queens',
    'JFK Airport',
    'Airports_V2',      -- Nouvelle valeur simulée
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
);

-- Étape C: vérification - on doit voir 2 lignes pour JFK Airport
SELECT
    location_key,
    location_id,
    zone,
    service_zone,
    valid_from,
    valid_to,
    is_current
FROM NYC_TAXI.STAGING.DIM_LOCATION
WHERE location_id = 132
ORDER BY valid_from;