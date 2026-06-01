# Troubleshooting — NYC Taxi Pipeline

## Problème 1 — Timestamps en microsecondes Unix

**Symptôme**  
Les colonnes `tpep_pickup_datetime` et `tpep_dropoff_datetime` 
affichent `Invalid date` après le COPY INTO initial.

**Cause**  
Les fichiers Parquet TLC 2024 stockent les timestamps en 
microsecondes Unix (ex: `1704070675000000`) et non en format 
TIMESTAMP standard.

**Solution**  
Utiliser `TO_TIMESTAMP(valeur::NUMBER, 6)` dans le COPY INTO 
au lieu du cast direct `::TIMESTAMP_NTZ`.

**Leçon**  
Toujours inspecter les valeurs brutes depuis le stage avant 
le chargement :
```sql
SELECT $1:tpep_pickup_datetime 
FROM @RAW.NYC_TAXI_STAGE/yellow_tripdata_2024-01.parquet
LIMIT 5;
```

## Problème 2 — COPY INTO refuse de recharger les fichiers

**Symptôme**  
Après correction du script, le COPY INTO ne recharge pas 
les fichiers déjà traités.

**Cause**  
Snowflake mémorise les fichiers déjà chargés dans un stage 
pour éviter les doublons.

**Solution**  
Ajouter `FORCE = TRUE` pour forcer le rechargement.
Toujours faire un `TRUNCATE TABLE` avant pour éviter les doublons.

## Problème 3 — Dates hors plage 2024-2025

**Symptôme**  
date_min = 2002-12-31, date_max = 2026-06-26 après chargement.

**Cause**  
51 lignes avec timestamps corrompus dans les fichiers source TLC.

**Solution**  
```sql
DELETE FROM RAW.YELLOW_TRIPS 
WHERE tpep_pickup_datetime > '2025-12-31';
```

**Résultat**  
51 lignes supprimées sur 44 644 946 — taux de rétention : 99.9999%
Données propres : 2024-01-01 → 2025-03-23
