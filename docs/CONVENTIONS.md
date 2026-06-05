# Conventions de code — NYC Taxi Pipeline

## SQL Snowflake
- Toujours utiliser les noms pleinement qualifiés :
  `DATABASE.SCHEMA.TABLE` (ex: `NYC_TAXI.STAGING.STG_TRIPS`)
- Éviter les `USE DATABASE` / `USE SCHEMA` dans les scripts 
  de production — réservés aux worksheets interactifs
- Préfixer les scripts par numéro d'ordre : `01_`, `02_`, etc.
- Un script = une responsabilité (setup, chargement, nettoyage...)

## Python
- Variables d'environnement via `.env` + `python-dotenv`
- Jamais de credentials en dur dans le code
- Fichier `.env` toujours dans `.gitignore`

## Git
- Commits avec format Conventional Commits :
  `feat:`, `fix:`, `docs:`, `chore:`

## DBT Core

### Structure des modèles
- `models/staging/` : vues de nettoyage (materialized='view')
- `models/marts/` : tables d'agrégats métier (materialized='table')
- Un fichier YAML par modèle pour les tests et la documentation
- Noms descriptifs : `stg_yellow_trips.yml` (pas `schema.yml`)

### Bonnes pratiques
- Utiliser `{{ source('nom_source', 'nom_table') }}` pour les tables RAW
- Utiliser `{{ ref('nom_modele') }}` pour référencer d'autres modèles dbt
- Noms de fichiers en snake_case : `stg_yellow_trips.sql`, `kpi_monthly.sql`
- Tests de qualité dans `schema.yml` (not_null, unique, relationships)



