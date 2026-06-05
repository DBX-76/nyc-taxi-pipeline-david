# NYC Taxi Project

[![DBT CI/CD Pipeline](https://github.com/DBX-76/nyc-taxi-pipeline-david/actions/workflows/dbt_ci.yml/badge.svg)](https://github.com/DBX-76/nyc-taxi-pipeline-david/actions/workflows/dbt_ci.yml)

Projet d'ingestion, stockage et analyse des données Yellow Taxi de New York City dans Snowflake.

## Vue d'ensemble

Ce projet automatise l'ingestion complète des données Yellow Taxi du TLC (Taxi and Limousine Commission) vers une infrastructure Snowflake. Les données sont téléchargées, transformées et mises à disposition pour l'analyse.

**Période couverte:** Janvier 2024 à Janvier 2025  
**Volume:** 134M+ lignes de trajets  
**Format source:** Parquet (CDN TLC)  
**Warehouse:** Snowflake

---

## Structure du projet

```
nyc-taxi-project/
├── README.md                    ← Vue d'ensemble (ce fichier)
├── .env                         ← Credentials Snowflake (à configurer)
├── .gitignore                   ← Fichiers à ignorer
├── requirements.txt             ← Dépendances Python
│
├── ingestion/
│   └── download_tlc.py          ← Script principal d'ingestion
│
├── sql/
│   ├── 01_setup_warehouse_database.sql    ← Setup warehouse & database
│   ├── 02_create_schemas.sql              ← Création des 3 schémas
│   ├── 03_create_raw_tables.sql           ← Tables RAW
│   ├── 04_load_taxi_zones.sql             ← Chargement zones
│   ├── 05_copy_yellow_trips.sql           ← COPY INTO YELLOW_TRIPS
│   ├── 06_data_quality_analysis.sql       ← Analyse qualité
│   ├── 07_create_staging.sql              ← Transformation staging
│   ├── 08_create_mart_kpis.sql            ← Tables KPIs
│   ├── 09a_create_dim_location.sql        ← Dimension location
│   ├── 09b_insert_dim_location.sql        ← Population dimension
│   ├── 09c_scd_type2_simulation.sql       ← SCD Type 2 démo
│   ├── 10_create_dbt_role.sql             ← Rôle DBT dédié
│   └── 11_monitoring_snowflake.sql        ← Monitoring Snowflake
│
├── data/
│   └── raw/                     ← Fichiers Parquet téléchargés
│
├── docs/
│   ├── CONVENTIONS.md           ← Standards SQL/Python
│   ├── TROUBLESHOOTING.md       ← Résolution de problèmes
│   ├── RAPPORT_QUALITE.md       ← Analyse qualité des données
│   ├── DASHBOARD.md             ← Documentation Streamlit
│   ├── MONITORING.md            ← Monitoring & Observabilité
│   ├── DBT_STRUCTURE.md         ← Structure DBT
│   ├── ARCHITECTURE.md          ← Architecture Snowflake & Medallion
│   ├── DATA_FLOW.md             ← Flux de données du pipeline
│   ├── SQL_TRANSFORMATIONS.md   ← Scripts SQL de transformation
│   └── erd_snowflake.png        ← Schéma ERD
│
├── nyc_taxi_dbt/                ← Projet DBT Core
│   ├── dbt_project.yml          ← Configuration DBT
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_yellow_trips.sql      ← Vue staging nettoyée
│   │   │   └── stg_yellow_trips.yml      ← Tests de qualité
│   │   └── marts/
│   │       ├── kpi_monthly.sql           ← KPI mensuels
│   │       ├── kpi_hourly.sql            ← KPI horaires
│   │       ├── kpi_zones.sql             ← KPI par zones
│   │       └── kpi_payment.sql           ← KPI par paiement
│   ├── seeds/, snapshots/, macros/       ← DBT components
│   └── .gitignore                       ← Ignore DBT artifacts
│
├── dashboard/                   ← Dashboard Streamlit
│   ├── app.py                 ← Application Streamlit
│   ├── snowflake_config.py    ← Configuration Snowflake
│   └── requirements.txt       ← Dépendances dashboard
│
└── monitoring/                  ← Monitoring & Grafana
    ├── docker-compose.yml       ← Docker Grafana (archive)
    └── dashboards/
        └── nyc_taxi_monitoring.json  ← Dashboard JSON
```



## Démarrage rapide

### 1. Configuration

**Prérequis:**
- Python 3.12
- Snowflake Account + Credentials
- Connexion internet

**Installation:**
```powershell
# Cloner le repo
git clone <repo-url>
cd nyc-taxi-project

# Créer l'environnement virtuel
python -m venv .venv

# Activer l'environnement
.venv\Scripts\Activate.ps1

# Installer les dépendances
pip install snowflake-connector-python requests python-dotenv tqdm
```

### 2. Configuration des credentials

Créer un fichier `.env` à la racine:
```bash
SNOWFLAKE_ACCOUNT=your_account_id
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=NYC_TAXI_WH
SNOWFLAKE_DATABASE=NYC_TAXI
SNOWFLAKE_ROLE=ACCOUNTADMIN
```

### 3. Lancer l'ingestion

**PowerShell (Windows):**
```powershell
# Lancer le script
python ingestion/download_tlc.py
```


## Sprints du projet

### Sprint 1 Ingestion & Architecture Snowflake
- **Architecture medallion:** `RAW` / `STAGING` / `MART`
- **Chargement `RAW.YELLOW_TRIPS`:** 44.6M lignes (Parquet 2024-2025)
- **Chargement `RAW.TAXI_ZONES`:** 265 zones
- **Script Python** `ingestion/download_tlc.py` (téléchargement + PUT + COPY INTO)
- **Troubleshooting documenté** (timestamps microsecondes, dates corrompues)
- **Fichiers SQL:**
  - `01_setup_warehouse_database.sql` — Création base + warehouse
  - `02_create_schemas.sql` — Schémas RAW, STAGING, MART
  - `03_create_raw_tables.sql` — Tables brutes
  - `04_load_taxi_zones.sql` — Zones (265 lignes)
  - `05_copy_yellow_trips.sql` — Chargement COPY INTO

### Sprint 2 Nettoyage, Qualité & Transformations SQL
- **Analyse qualité:** 86.1% de rétention (38.4M / 44.6M lignes)
- **Création `STAGING.STG_TRIPS`:** 38.4M lignes propres et validées
- **SCD Type 2 `STAGING.DIM_LOCATION`:** Démonstration JFK Airport
- **4 tables KPIs dans `MART`:**
  - `MART.KPI_MONTHLY` — Agrégations mensuelles
  - `MART.KPI_HOURLY` — Agrégations horaires
  - `MART.KPI_BY_ZONE` — Anályses par zone
  - `MART.KPI_BY_PAYMENT` — Anályses par type de paiement
- **Documentation:**
  - `docs/RAPPORT_QUALITE.md` — Analyse détaillée des données
  - `docs/CONVENTIONS.md` — Standards de code SQL/Python
  - `docs/TROUBLESHOOTING.md` — Résolution de problèmes
  - `docs/erd_snowflake.png` — Schéma ERD du warehouse
- **Fichiers SQL:**
  - `06_data_quality_analysis.sql` — Analyse préliminaire
  - `07_create_staging.sql` — Transformation vers STG_TRIPS
  - `08_create_mart_kpis.sql` — Tables KPIs
  - `09a_create_dim_location.sql` — Dimension de localisation
  - `09b_insert_dim_location.sql` — Population de la dimension
  - `09c_scd_type2_simulation.sql` — Démonstration SCD Type 2

### Sprint 3 DBT Core 
- Installation de `dbt-core` (1.11.11) et `dbt-snowflake` (1.11.5)
- Création du rôle dédié `DBT_ROLE` dans Snowflake
- Configuration du `profiles.yml` et connexion à Snowflake Azure
- Test de connexion validé (`dbt debug` OK)
- Modèle staging `stg_yellow_trips` créé (vue, 38.4M lignes nettoyées)
- 4 Modèles marts créés (tables dans PUBLIC_mart : monthly, hourly, zones, payment)
- Tests de qualité `not_null` validés (PASS=3)
- Structure YAML modernisée (1 fichier YAML par modèle)
- Documentation automatique générée (`dbt docs generate`)
- Data Lineage visualisé via `dbt docs serve`

### Sprint 4 CI/CD & Automatisation (GitHub Actions)
- Pipeline CI/CD opérationnel (déclenché à chaque push sur `main`)
- Étapes : `dbt compile` -> `dbt test` -> `dbt run`
- Performance : Pipeline exécuté en ~20s pour 38.4M lignes
- Sécurisation : Identifiants Snowflake gérés via GitHub Secrets

### Sprint 5 Monitoring & Observabilité 
- Data Freshness : Surveillance de la fraîcheur des données via `dbt source freshness`
- Monitoring des performances Snowflake (Requêtes sur `ACCOUNT_USAGE` et `INFORMATION_SCHEMA`)
- Gestion fine des tables statiques vs dynamiques dans les tests de fraîcheur
- Détection des requêtes lentes et estimation du stockage

### Sprint 6 Dashboard de visualisation Streamlit
- Dashboard interactif connecté à Snowflake en temps réel
- 4 KPIs principaux : courses, revenus, distance, pourboires
- 4 visualisations : évolution mensuelle, répartition horaire, top zones, paiements
- Optimisation pushdown SQL : agrégations côté Snowflake (pas de transfert de 38M lignes)
- Cache intelligent Streamlit (TTL 1h) pour performances optimales
- Sécurité : credentials via variables d'environnement (.env)
- UI épurée : focus sur la donnée, pas de filtres inutiles

### Sprint 7 Monitoring avancé avec Grafana 
- Configuration Docker pour Grafana local (archive - plugin Snowflake devenu payant)
- Migration vers Grafana Cloud (essai Enterprise 14 jours)
- Dashboard de monitoring avec 4 panneaux : fraîcheur, volume, performance, stockage
- Détection automatique de la fraîcheur (437 jours sans nouvelles données)
- Export JSON du dashboard pour Infrastructure as Code


## Vérification 

### Fichiers téléchargés localement:
```powershell
ls data/raw/
```
Vous devriez voir: `yellow_tripdata_2024-01.parquet` ... `yellow_tripdata_2025-01.parquet`

### Vérification dans Snowflake:
```sql
-- Nombre de lignes par table
SELECT 'RAW.YELLOW_TRIPS' as table_name, COUNT(*) as row_count FROM NYC_TAXI.RAW.YELLOW_TRIPS
UNION ALL
SELECT 'STAGING.STG_TRIPS', COUNT(*) FROM NYC_TAXI.STAGING.STG_TRIPS
UNION ALL
SELECT 'MART.KPI_MONTHLY', COUNT(*) FROM NYC_TAXI.MART.KPI_MONTHLY;
```

### Données dans Snowflake:
```sql
-- Vérifier le nombre de lignes
SELECT COUNT(*) FROM RAW.YELLOW_TRIPS;

-- Voir un exemple
SELECT * FROM RAW.YELLOW_TRIPS LIMIT 5;

-- Lister les fichiers uploadés
LIST @RAW.NYC_TAXI_STAGE;
```


## Documentation

### Architecture & Conception
- [Architecture Snowflake & Medallion](docs/ARCHITECTURE.md)
- [DBT Core Structure](docs/DBT_STRUCTURE.md) — Modèles, tests, bonnes pratiques
- [Flux de données](docs/DATA_FLOW.md) — Ingestion → Staging → MART

### Transformations & Qualité
- [Requêtes SQL](docs/SQL_TRANSFORMATIONS.md) — Scripts de transformation
- [Rapport qualité données](docs/RAPPORT_QUALITE.md) — Nettoyage et KPIs

### Monitoring & Dashboard
- [Dashboard Streamlit](docs/DASHBOARD.md) — Visualisations interactives
- [Monitoring & Observabilité](docs/MONITORING.md) — Fraîcheur, performances, CI/CD

### Références
- [Conventions de code](docs/CONVENTIONS.md) — Standards SQL/Python/DBT
- [Troubleshooting](docs/TROUBLESHOOTING.md) — Résolution de problèmes

---

## Configuration Snowflake

Le script crée/utilise automatiquement:
- **Database:** `NYC_TAXI`
- **Schema:** `RAW`
- **Table:** `YELLOW_TRIPS`
- **Stage:** `@RAW.NYC_TAXI_STAGE`

---

## Dernière mise à jour

- **Date:** 4 Juin 2026
- **État:** Phase 7 - Dashboard + Monitoring ✅
- **Documentation:** Tous les guides disponibles dans `docs/`




