# Architecture Snowflake — NYC Taxi Pipeline

## Architecture Medallion (3 schémas)

```
┌─────────────────────────────────────────────────────────────────┐
│  RAW (Brut)                                                     │
│  └── Données ingérées telles quelles                            │
│      - YELLOW_TRIPS : 44.6M lignes (Parquet)                    │
│      - TAXI_ZONES : 265 zones géographiques                     │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGING (Nettoyage)                                            │
│  └── Transformations et qualité des données                     │
│      - STG_TRIPS : 38.4M lignes (Vue DBT)                       │
│      - DIM_LOCATION : Démonstration SCD Type 2                  │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  MART (Agrégats)                                                │
│  └── Tables KPI pour le business                                │
│      - KPI_MONTHLY : 13 mois d'agrégations                      │
│      - KPI_HOURLY : 24 heures                                   │
│      - KPI_BY_ZONE : Top 20 zones                               │
│      - KPI_BY_PAYMENT : 5 types paiement                        │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Snowflake

| Élément           | Valeur         | Description 
|-------------------|----------------|---------------------------
| Database          | NYC_TAXI       | Base de données principale 
| Warehouse         | NYC_TAXI_WH    | Entrepôt de calcul 
| Schema RAW        | Données brutes | Staging S3 → Snowflake 
| Schema STAGING    | Nettoyage      | Vue DBT `stg_yellow_trips` 
| Schema MART       | KPI business   | Tables agrégées 

## Pipeline d'ingestion

1. **Téléchargement**  : Script Python `download_tlc.py` → fichiers Parquet locaux
2. **Upload**          : PUT command → Stage Snowflake `@RAW.NYC_TAXI_STAGE`
3. **Chargement**      : COPY INTO → Table `RAW.YELLOW_TRIPS`
4. **Transformations** : DBT → Vue `STAGING.stg_yellow_trips`
5. **Agrégations**     : DBT → Tables `MART.*`

## Schéma ERD

Voir `docs/erd_snowflake.png` pour le diagramme complet des relations entre tables.