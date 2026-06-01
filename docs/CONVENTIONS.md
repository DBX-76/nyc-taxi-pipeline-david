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

