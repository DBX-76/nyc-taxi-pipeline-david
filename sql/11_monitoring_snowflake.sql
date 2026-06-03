-- 1. Historique des exécutions DBT (Dernières 24h)
-- Permet de voir le temps d'exécution des modèles
SELECT 
    start_time,
    query_type,
    LEFT(query_text, 100) AS query_snippet,
    execution_status,
    total_elapsed_time/1000 AS elapsed_seconds,
    bytes_scanned/1024/1024 AS mb_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE user_name = 'SNOWFLAKEDBX' -- ⚠️ Remplace par ton vrai user si besoin
  AND start_time >= DATEADD('hour', -24, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 20;

-- 2. Estimation de la taille des tables (Surveillance du stockage)
-- Vérifie combien de Mo/Go prend chaque schéma
SELECT 
    table_schema,
    table_name,
    row_count,
    ROUND(bytes/1024/1024, 2) AS size_mb,
    last_altered
FROM NYC_TAXI.INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('RAW', 'PUBLIC_STAGING', 'PUBLIC_MART')
ORDER BY bytes DESC;

-- 3. Détection des requêtes lentes (Optimisation)
-- Utile pour repérer les modèles qui consomment trop de ressources
SELECT 
    start_time,
    LEFT(query_text, 80) AS query_snippet,
    total_elapsed_time/1000 AS elapsed_seconds,
    partitions_scanned,
    partitions_total
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE total_elapsed_time > 5000 -- > 5 secondes
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY total_elapsed_time DESC
LIMIT 10;