 # Monitoring - NYC Taxi Pipeline


### Phase 1 : Grafana Local avec Docker (Abandonné)
- **Objectif** : Déployer Grafana en local via Docker Compose
- **Fichiers** : `docker-compose.yml`
- **Problème rencontré** : Le plugin officiel Snowflake (`grafana-snowflake-datasource`) est passé en licence Enterprise (payante) en 2024
- **Décision** : Migration vers Grafana Cloud pour bénéficier de l'essai gratuit Enterprise (14 jours)

### Phase 2 : Grafana Cloud 
- **Objectif** : Utiliser Grafana Cloud pour le monitoring
- **Avantages** :
  - Accès à tous les plugins Enterprise (gratuit 14 jours)
  - Lien partageable pour le jury
  - Pas besoin de Docker sur la machine
- **Dashboards** : Exportés en JSON et commités dans ce dossier (à venir)

## Fichiers

- `docker-compose.yml` : Configuration Docker pour Grafana local (archive)
- `dashboards/` : Dashboards Grafana exportés en JSON
