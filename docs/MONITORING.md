# Stratégie de Monitoring & Observabilité (Sprint 5)

Pour garantir la fiabilité du pipeline en production, 3 niveaux de monitoring ont été mis en place :

## 1. Data Freshness (Fraîcheur des données)
Utilisation de la fonctionnalité native de dbt (`dbt source freshness`).
- **Cible** : Table `RAW.YELLOW_TRIPS`
- **Seuils** : Warning à 30 jours, Error à 90 jours.
- **Résultat** : Le système détecte correctement l'absence de nouvelles données (Status: `ERROR STALE`), ce qui déclencherait une alerte en production.

## 2. Monitoring des performances Snowflake
Requêtes SQL sur le dictionnaire de données `SNOWFLAKE.ACCOUNT_USAGE` et `INFORMATION_SCHEMA` (fichier `sql/11_monitoring_snowflake.sql`).
- **Temps d'exécution** : Surveillance de la durée des `CREATE_TABLE_AS_SELECT` (actuellement ~12s pour 38M de lignes).
- **Stockage** : Suivi de la taille des tables (RAW = 1 Go, MART = 931 Mo).
- **Requêtes lentes** : Identification des requêtes > 5 secondes pour optimisation future.

## 3. CI/CD Monitoring (GitHub Actions)
- Historique complet des exécutions disponible dans l'onglet "Actions" de GitHub.
- Temps total du pipeline : ~20 secondes.