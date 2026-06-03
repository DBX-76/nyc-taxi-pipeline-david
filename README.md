# NYC Taxi Project

Projet d'ingestion, stockage et analyse des données Yellow Taxi de New York City (2024-2025) dans Snowflake.

## Vue d'ensemble

Ce projet automatise l'ingestion complète des données Yellow Taxi du TLC (Taxi and Limousine Commission) vers une infrastructure Snowflake. Les données sont téléchargées, transformées et mises à disposition pour l'analyse.

**Période couverte:** Janvier 2024 à Janvier 2025  
**Volume:** 134M+ lignes de trajets  
**Format source:** Parquet (CDN TLC)  
**Warehouse:** Snowflake

---

## Architecture du Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TLC NYC Taxi Data Pipeline                         │
└─────────────────────────────────────────────────────────────────────────────┘

SPRINT 1 — INGESTION & ARCHITECTURE SNOWFLAKE
┌──────────────────────────────────────────────────────────────────────────────┐
│
│  TLC CDN (Parquet 2024-2025)
│         ↓
│  Python Script (download_tlc.py)
│    • Télécharge mois par mois
│    • Stockage local data/raw/
│    • Upload vers Snowflake Stage
│    • COPY INTO RAW.YELLOW_TRIPS
│         ↓
│  Snowflake RAW Schema (44.6M lignes)
│    ├── RAW.YELLOW_TRIPS (44.6M trajets)
│    └── RAW.TAXI_ZONES (265 zones)
│
└──────────────────────────────────────────────────────────────────────────────┘

SPRINT 2 — NETTOYAGE, QUALITÉ & TRANSFORMATIONS
┌──────────────────────────────────────────────────────────────────────────────┐
│
│  Analyse Qualité (06_data_quality_analysis.sql)
│    • 86.1% de rétention (38.4M / 44.6M)
│    • Exclusion données corrompues, NULL, durées aberrantes
│         ↓
│  STAGING Schema (38.4M lignes propres)
│    ├── STG_TRIPS (38.4M trajets validés)
│    ├── DIM_LOCATION (SCD Type 2)
│    └── (Tables intermédiaires)
│         ↓
│  MART Schema (Tables KPIs d'analyse)
│    ├── KPI_MONTHLY (agrégations mensuelles)
│    ├── KPI_HOURLY (agrégations horaires)
│    ├── KPI_BY_ZONE (analyses par zone)
│    └── KPI_BY_PAYMENT (analyses par paiement)
│
│  Documentation Complète
│    ├── RAPPORT_QUALITE.md (détails anomalies)
│    ├── CONVENTIONS.md (standards)
│    ├── TROUBLESHOOTING.md (solutions)
│    └── erd_snowflake.png (schéma)
│
└──────────────────────────────────────────────────────────────────────────────┘

SPRINT 3 [EN COURS] — DBT CORE (EN COURS)
┌──────────────────────────────────────────────────────────────────────────────┐
│
│  dbt Project
│    ├── Models (staging, marts)
│    ├── Tests qualité automatisés
│    ├── Documentation dbt
│    ├── Sources + Seeds
│    └── Lineage complet
│
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Structure du projet

```
nyc-taxi-project/
├── README.md                    ← Vue d'ensemble (ce fichier)
├── .env                         ← Credentials Snowflake (à configurer)
├── .gitignore                   ← Fichiers à ignorer
├── .venv/                       ← Environnement Python virtuel
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
│   └── 09c_scd_type2_simulation.sql       ← SCD Type 2 démo
│
├── data/
│   └── raw/                     ← Fichiers Parquet téléchargés
│
└── docs/
    ├── CONVENTIONS.md           ← Standards SQL/Python
    ├── TROUBLESHOOTING.md       ← Résolution de problèmes
    ├── RAPPORT_QUALITE.md       ← Analyse qualité des données
    └── erd_snowflake.png        ← Schéma ERD
```

---

## Démarrage rapide

### 1. Configuration

**Prérequis:**
- Python 3.8+
- Snowflake Account + Credentials
- Connexion internet

**Installation:**
```powershell
# Cloner le repo
git clone <repo-url>
cd nyc-taxi-project

# Créer l'environnement virtuel (si pas encore fait)
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
# Activer l'environnement (si pas déjà fait)
.venv\Scripts\Activate.ps1

# Lancer le script
python ingestion/download_tlc.py
```

**Bash (Linux/Mac):**
```bash
source .venv/bin/activate
python ingestion/download_tlc.py
```

---

## État du projet

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

---

## Vérification du succès

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

---

## Documentation

- [Architecture détaillée](docs/ARCHITECTURE.md) *(À compléter)*
- [Flux de données](docs/DATA_FLOW.md) *(À compléter)*
- [Requêtes SQL](docs/SQL_TRANSFORMATIONS.md) *(À compléter)*

---

## Configuration Snowflake

Le script crée/utilise automatiquement:
- **Database:** `NYC_TAXI`
- **Schema:** `RAW`
- **Table:** `YELLOW_TRIPS`
- **Stage:** `@RAW.NYC_TAXI_STAGE`

---

## Troubleshooting

### Erreur: "snowflake.connector not found"
```powershell
pip install snowflake-connector-python
```

### Erreur: Credentials invalides
- Vérifier le fichier `.env`
- Vérifier les credentials Snowflake
- S'assurer que le warehouse est actif

### Erreur: Fichiers introuvables
- Certains fichiers Yellow Taxi ne sont pas encore publiés
- Le script affiche `[warn]` pour les fichiers manquants

---

## Prochaines étapes

1. **Remplir la Phase 2** - Créer les scripts SQL de transformation
2. **Ajouter des tests** - Validation des données
3. **Documentation complète** - Créer `docs/ARCHITECTURE.md`
4. **Monitoring** - Logs et alertes

---

## Support

Pour toute question, consultez:
- La documentation Snowflake: [docs.snowflake.com](https://docs.snowflake.com)
- Les données TLC: [www.nyc.gov/tlc](https://www.nyc.gov/tlc)

---

## Dernière mise à jour

- **Date:** 1er Juin 2026
- **État:** Phase 1 - Ingestion complète ✅
- **Prochaine révision:** Lors de l'ajout des transformations
