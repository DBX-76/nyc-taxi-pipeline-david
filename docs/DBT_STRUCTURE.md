Voici le contenu complet et mis à jour du fichier `docs/DBT_STRUCTURE.md`. J'ai remplacé la section "Structure du projet" par votre nouvelle version qui inclut les fichiers de configuration YAML spécifiques (`stg_yellow_trips.yml`) et des commentaires plus précis, tout en conservant le reste du document intact.

Vous pouvez copier-coller l'intégralité du bloc ci-dessous :

```markdown
# Architecture DBT - NYC Taxi Pipeline

## Vue d'ensemble

Ce projet utilise **dbt Core** (data build tool) pour industrialiser les transformations SQL et les intégrer dans un pipeline CI/CD. dbt permet de :
- Modulariser le SQL en fichiers `.sql` versionnés
- Tester automatiquement la qualité des données
- Documenter les tables et colonnes
- Gérer les dépendances entre modèles (graphe DAG)

## Structure du projet

```text
nyc_taxi_dbt/
├── dbt_project.yml              # Configuration centrale
├── models/
│   ├── staging/
│   │   ├── src_nyc_taxi.yml     # Déclaration des sources RAW (Sources)
│   │   ├── stg_yellow_trips.yml # Tests de qualité et doc du modèle Staging
│   │   └── stg_yellow_trips.sql # Code SQL de nettoyage
│   └── marts/
│       ├── kpi_monthly.sql      # KPIs mensuels
│       ├── kpi_hourly.sql       # KPIs par heure
│       ├── kpi_zones.sql        # KPIs par zone (Top 20)
│       └── kpi_payment.sql      # KPIs par type de paiement
├── seeds/                       # Fichiers CSV statiques (futur)
├── tests/                       # Tests personnalisés (futur)
├── macros/                      # Fonctions SQL réutilisables (futur)
└── snapshots/                   # SCD Type 2 (futur)
```

## Flux de données (Data Lineage)

```text
┌─────────────────────────────────────────────────────────────┐
│  RAW (Snowflake)                                            │
│  ├── RAW.YELLOW_TRIPS (44.6M lignes brutes)                │
│  └── RAW.TAXI_ZONES (265 zones)                            │
└────────────────────┬────────────────────────────────────────┘
                     │ {{ source('raw_nyc_taxi', 'YELLOW_TRIPS') }}
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGING (Vue)                                              │
│  └── stg_yellow_trips (38.4M lignes nettoyées)             │
│      - Filtrage : passenger_count > 0, trip_distance > 0   │
│      - Calculs : trip_duration_min, tip_percentage         │
│      - Extraction : pickup_hour, pickup_month, pickup_year │
└────────────────────┬────────────────────────────────────────┘
                     │ {{ ref('stg_yellow_trips') }}
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  MART (Tables)                                              │
│  ├── kpi_monthly (13 mois : jan 2024 → jan 2025)           │
│  ├── kpi_hourly (24 heures)                                │
│  ├── kpi_zones (top 20 zones)                              │
│  └── kpi_payment (5 types de paiement)                     │
└─────────────────────────────────────────────────────────────┘
```

## Modèles créés

### Staging : `stg_yellow_trips`

**Type** : Vue (`materialized='view'`)  
**Objectif** : Nettoyer et préparer les données brutes pour les analyses

**Règles de nettoyage appliquées** :
- `passenger_count` NOT NULL, > 0 et <= 6
- `trip_distance` > 0
- `fare_amount` >= 0 et `total_amount` >= 0
- Durée trajet > 0 et <= 24h
- `payment_type` != 0
- Exclusion des résidus corrompus (fév-mars 2025)

**Calculs ajoutés** :
- `trip_duration_min` : durée en minutes
- `tip_percentage` : pourcentage pourboire
- `pickup_hour`, `pickup_dow`, `pickup_month`, `pickup_year` : extraction temporelle

**Résultat** : 38 448 590 lignes (taux de rétention 86.1%)

### Marts : KPIs métier

#### `kpi_monthly`
**Type** : Table (`materialized='table'`)  
**Granularité** : Année + Mois  
**Métriques** : `nb_courses`, `distance_moyenne_km`, `duree_moyenne_min`, `tarif_moyen`, `total_moyen`, `pourboire_moyen_pct`, `revenu_total`, `pourboires_total`

#### `kpi_hourly`
**Type** : Table  
**Granularité** : Heure de la journée (0-23)  
**Métriques** : `nb_courses`, `distance_moyenne`, `total_moyen`, `pourboire_moyen_pct`

#### `kpi_zones`
**Type** : Table  
**Granularité** : Zone de pickup (top 20)  
**Jointure** : `stg_yellow_trips` ⟕ `TAXI_ZONES` sur `PULocationID`  
**Métriques** : `nb_courses`, `total_moyen`, `distance_moyenne`, `revenu_total`

#### `kpi_payment`
**Type** : Table  
**Granularité** : Type de paiement (1-5)  
**Métriques** : `nb_courses`, `pct_total`, `total_moyen`

## Tests de qualité

Fichier `models/staging/stg_yellow_trips.yml` :

```yaml
version: 2

models:
  - name: stg_yellow_trips
    description: "Vue nettoyée des trajets Yellow Taxi"
    columns:
      - name: VendorID
        tests:
          - not_null
      - name: tpep_pickup_datetime
        tests:
          - not_null
      - name: passenger_count
        tests:
          - not_null
```

**Résultat** : PASS=3 (100% des données respectent les contraintes)

## Bonnes pratiques dbt appliquées

### 1. Utilisation des sources
Au lieu d'écrire en dur `NYC_TAXI.RAW.YELLOW_TRIPS`, on déclare les sources dans `src_nyc_taxi.yml` :

```sql
-- ❌ Mauvaise pratique
SELECT * FROM NYC_TAXI.RAW.YELLOW_TRIPS

-- ✅ Bonne pratique
SELECT * FROM {{ source('raw_nyc_taxi', 'YELLOW_TRIPS') }}
```

**Avantages** :
- dbt crée automatiquement le graphe de dépendances
- Si le nom de la table change, on modifie un seul fichier YAML
- Documentation automatique des sources

### 2. Utilisation des références
Pour référencer un modèle dbt dans un autre :

```sql
-- ❌ Mauvaise pratique
SELECT * FROM NYC_TAXI.STAGING.stg_yellow_trips

-- ✅ Bonne pratique
SELECT * FROM {{ ref('stg_yellow_trips') }}
```

**Avantages** :
- dbt comprend la dépendance et exécute les modèles dans le bon ordre
- Si `stg_yellow_trips` change de schéma, `kpi_monthly` est automatiquement mis à jour

### 3. Configuration centralisée
Dans `dbt_project.yml`, on définit le comportement par dossier :

```yaml
models:
  nyc_taxi_dbt:
    staging:
      +materialized: view      # Tous les fichiers staging/ seront des vues
      +schema: staging
    marts:
      +materialized: table     # Tous les fichiers marts/ seront des tables
      +schema: mart
```

**Avantage** : Pas besoin de répéter `{{ config(materialized='view') }}` dans chaque fichier SQL.

## Commandes dbt principales

```bash
# Compiler les modèles (sans exécuter)
dbt compile

# Exécuter tous les modèles
dbt run

# Exécuter un modèle spécifique
dbt run --select kpi_monthly

# Lancer les tests de qualité
dbt test

# Générer la documentation
dbt docs generate

# Servir la documentation localement
dbt docs serve

# Vérifier la connexion
dbt debug
```

## Configuration de connexion

Fichier `~/.dbt/profiles.yml` :

```yaml
nyc_taxi_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: BUBVHEX-WP48974
      user: SNOWFLAKEDBX
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: ACCOUNTADMIN
      database: NYC_TAXI
      warehouse: NYC_TAXI_WH
      schema: PUBLIC
      threads: 4
```

**Note** : Le mot de passe est stocké dans une variable d'environnement pour des raisons de sécurité.

## Documentation automatique & Data Lineage

### Génération de la documentation

dbt peut générer automatiquement un site web interactif qui documente :
- Les sources de données
- Les modèles (SQL, descriptions, colonnes)
- Les tests de qualité
- Les dépendances entre les modèles (DAG)

**Commandes :**
```bash
dbt docs generate  # Génère les fichiers dans target/
dbt docs serve     # Lance un serveur web local (http://localhost:8080)

## Intégration CI/CD (futur)

Pipeline GitHub Actions prévu :

```yaml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  dbt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      
      - name: Install dbt
        run: pip install dbt-core dbt-snowflake
      
      - name: dbt compile (PR)
        if: github.event_name == 'pull_request'
        run: dbt compile
      
      - name: dbt test (PR)
        if: github.event_name == 'pull_request'
        run: dbt test
      
      - name: dbt run (main)
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: dbt run
```

**Flux** :
- **Pull Request** : `dbt compile` + `dbt test` (validation sans déploiement)
- **Merge vers main** : `dbt run` (déploiement en production)

## Compétences validées

- **C11** : Architecture Snowflake (warehouse, database, schemas)
- **C13** : Modélisation en étoile (dimensions + faits)
- **C14** : Transformation SQL avancée (CTE, window functions)
- **C15** : Pipeline ETL automatisé (Python + dbt)
- **C17** : Qualité des données (tests dbt, SCD Type 2)

## Ressources

- [Documentation officielle dbt](https://docs.getdbt.com/)
- [Article de référence : dbt + Snowflake](https://dipikajiandani.medium.com/dbt-snowflake-2831681b67f9)
- [Snowflake Documentation](https://docs.snowflake.com/)
```