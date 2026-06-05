# Requêtes SQL — NYC Taxi Pipeline

## Scripts d'architecture (01-04)

### 01_setup_warehouse_database.sql
Création du warehouse et de la base de données :
- Warehouse : NYC_TAXI_WH
- Base : NYC_TAXI
- Configuration des paramètres de performance

### 02_create_schemas.sql
Création des 3 schémas :
- RAW (données brutes)
- STAGING (nettoyage)
- MART (agrégats métier)

### 03_create_raw_tables.sql
Tables RAW :
- YELLOW_TRIPS (structure identique aux fichiers Parquet)
- NYC_TAXI_STAGE (stage interne pour l'ingestion)

### 04_load_taxi_zones.sql
Chargement des zones géographiques :
- 265 zones NYC
- Jointure avec les trajets pour le KPI zones

## Scripts de transformation (05-11)

### 05_copy_yellow_trips.sql
Chargement des données Parquet :
```sql
COPY INTO NYC_TAXI.RAW.YELLOW_TRIPS
FROM @RAW.NYC_TAXI_STAGE
FILE_FORMAT = (TYPE = PARQUET)
PATTERN = '.*yellow_tripdata_2024.*\.parquet';
```

### 06_data_quality_analysis.sql
Analyse préliminaire :
- Détection des valeurs NULL
- Identification des anomalies (distances négatives, durées > 24h)
- Statistiques descriptives

### 07_create_staging.sql
Vue STG_TRIPS avec nettoyage :
- Filtre passenger_count > 0 et <= 6
- Filtre trip_distance > 0
- Calcul de trip_duration_min et tip_percentage
- Extraction des dimensions temporelles

### 08_create_mart_kpis.sql
4 tables KPI :
- KPI_MONTHLY : Agrégations par mois
- KPI_HOURLY : Agrégations par heure
- KPI_ZONES : Top 20 zones par courses
- KPI_PAYMENT : Répartition par type paiement

### 09a-09c : Dimension Location & SCD Type 2

#### 09a_create_dim_location.sql
Création de la dimension avec colonnes de validité :
- location_key (surrogate)
- valid_from, valid_to, is_current

#### 09b_insert_dim_location.sql
Population initiale depuis TAXI_ZONES

#### 09c_scd_type2_simulation.sql
Démonstration : changement de service_zone pour JFK Airport

### 10_create_dbt_role.sql
Création du rôle DBT_ROLE avec permissions :
- USAGE sur warehouse
- SELECT sur RAW
- CREATE sur STAGING et MART

### 11_monitoring_snowflake.sql
Requêtes de monitoring :
- Requêtes lentes (> 5s)
- Taille des tables par schéma
- Utilisation du warehouse
- ACCOUNT_USAGE queries


