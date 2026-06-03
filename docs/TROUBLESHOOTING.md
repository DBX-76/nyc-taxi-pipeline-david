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

## Problème 4 - Incompatibilité dbt avec Python 3.14

**Symptôme** : 
Erreur `mashumaro.exceptions.UnserializableField` lors de l'exécution de `dbt --version` ou `dbt debug`.

**Cause** : 
Python 3.14 est une version très récente (encore en phase de développement/bêta). Les dépendances internes de dbt (notamment `mashumaro` et `dbt_common`) ne sont pas encore compatibles avec cette version.

**Solution** : 
1. Installer la dernière version stable supportée (Python 3.12).
2. Supprimer l'ancien environnement virtuel : `Remove-Item -Recurse -Force .venv`
3. Recréer l'environnement avec Python 3.12 : `py -3.12 -m venv .venv`
4. Réinstaller les dépendances.

## Problème 5 - Le bug de la double extension Windows
**Symptôme** : Git détecte un fichier nommé `stg_yellow_trips.yml.yml` au lieu de `stg_yellow_trips.yml`.
**Cause** : Windows masque souvent les extensions de fichiers connus. En renommant `schema.yml` en `stg_yellow_trips.yml` via l'explorateur, Windows a ajouté le `.yml` à la fin du nom complet.
**Solution** : Utiliser Git pour forcer le renommage : `git mv stg_yellow_trips.yml.yml stg_yellow_trips.yml`. Toujours activer l'affichage des extensions de fichiers dans Windows.

## Problème 6 - DBT Custom Schemas (`PUBLIC_mart` au lieu de `MART`)
**Symptôme** : DBT crée les tables dans un schéma nommé `PUBLIC_mart` au lieu de simplement `MART`.
**Cause** : DBT combine par défaut le schéma cible du `profiles.yml` (`PUBLIC`) avec le suffixe défini dans `dbt_project.yml` (`_mart`).
**Solution** : C'est le comportement natif ("Custom Schemas") de DBT. Pour un projet de formation, c'est parfaitement acceptable. Pour la production, on configure les schémas cibles de manière explicite dans le `profiles.yml` ou via des variables d'environnement.

## Problème 7 - Erreur de fraîcheur sur une table statique (TAXI_ZONES)
**Symptôme** : La commande `dbt source freshness` échoue avec l'erreur `invalid identifier 'TPEP_PICKUP_DATETIME'`.
**Cause** : Les règles de `freshness` et `loaded_at_field` avaient été définies au niveau de la source globale (`raw_nyc_taxi`). dbt a donc tenté de chercher la colonne `tpep_pickup_datetime` dans TOUTES les tables de la source, y compris `TAXI_ZONES` qui est une table de référence statique.
**Solution** : Retirer les règles du niveau "source" et les appliquer uniquement au niveau de la table dynamique `YELLOW_TRIPS` dans le fichier `src_nyc_taxi.yml`. Les tables statiques (lookup) ne doivent jamais avoir de contrôle de fraîcheur.

## Problème 8- Erreur de connexion Snowflake depuis Streamlit
**Symptôme** : `Failed to connect to DB: Incorrect username or password was specified`
**Cause** : Le mot de passe était en dur dans le code ou les variables d'environnement n'étaient pas chargées.
**Solution** : Utiliser `python-dotenv` pour charger le fichier `.env` depuis la racine du projet. Ne jamais mettre de credentials en dur dans le code.

## Problème 9 - Erreur de mémoire Pandas avec 38M de lignes
**Symptôme** : `numpy._core._exceptions._ArrayMemoryError: Unable to allocate 2.86 GiB for an array with shape (10, 38448590)`
**Cause** : Le dashboard chargeait toutes les lignes de la table `KPI_MONTHLY` (38.4M lignes) au lieu des données agrégées (~13 lignes).
**Solution** : Déplacer les agrégations côté Snowflake (pushdown SQL) plutôt que de charger les données brutes en mémoire Python. Utiliser `GROUP BY` dans les requêtes SQL au lieu de `SELECT *`.


## Problème 10 - Port 3000 déjà alloué pour Grafana

**Symptôme**  
```
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint nyc_taxi_grafana: Bind for 0.0.0.0:3000 failed: port is already allocated
```

**Cause**  
Le port 3000 est déjà utilisé par un autre service sur la machine (Node.js, React, un autre conteneur Docker, ou une précédente instance de Grafana).

**Solution**  

1. **Modifier le port dans `docker-compose.yml`**  
   Changez la mapping de port pour utiliser un port différent :
   ```yaml
   ports:
     - "3001:3000"  # Utiliser le port 3001 au lieu de 3000
   ```
2. **Relancer le conteneur**  
   ```bash
   docker compose up -d
   ```
3. **Accéder à Grafana**  
   Ouvrez `http://localhost:3001` dans votre navigateur.

**Alternative : Libérer le port 3000**  

Trouvez et arrêtez le processus qui utilise le port 3000 :

```powershell
# Windows : trouver le processus utilisant le port 3000
netstat -ano | findstr :3000

# Tuer le processus (remplacez <PID> par le numéro trouvé)
taskkill /PID <PID> /F
```
Voici une version restructurée et corrigée de votre marque d'arme, avec un ton plus professionnel et une mise en forme claire pour une présentation ou un rapport.

***

### Problème 11 : Restriction de licence du plugin Snowflake pour Grafana

**Symptôme**
Impossibilité d'utiliser le connecteur natif Snowflake sur une instance Grafana open-source auto-hébergée.

**Cause racine**
Depuis 2024, le plugin officiel Snowflake pour Grafana est passé sous licence **Enterprise (payante)**. Il n'est plus disponible pour les versions open-source standards, bloquant ainsi l'intégration directe sans achat de licence.

**Solutions de contournement identifiées**
1.  **Grafana Cloud (Recommandé)** : Profiter de l'essai gratuit de 14 jours incluant tous les plugins Enterprise. Permet un déploiement rapide et le partage public du dashboard.
2.  **Driver ODBC générique** : Contourner le plugin officiel en utilisant un driver ODBC Snowflake couplé au plugin de données générique de Grafana (configuration complexe).
3.  **Alternative Python (Streamlit)** : Abandonner Grafana pour développer un dashboard de monitoring sur mesure en Python pur avec Streamlit.

**Décision stratégique pour le projet**
Adoption de **Grafana Cloud** via l'offre d'essai gratuit.
*Justification* : Cette option garantit l'accès immédiat à tous les plugins Enterprise sans friction technique et permet de générer un lien public sécurisé pour la présentation devant le jury.

**Leçon retenue**
La viabilité d'une stack technique ne doit jamais être présumée acquise. Il est impératif de **vérifier systématiquement les conditions de licence des plugins et dépendances** avant l'architecture finale. Une solution open-source peut devenir payante du jour au lendemain, menaçant la continuité du projet.
