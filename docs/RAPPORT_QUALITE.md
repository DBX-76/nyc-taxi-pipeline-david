# Rapport Qualité des Données — NYC Yellow Taxi 2024-2025

## 1. Source des données
- **Origine** : NYC TLC Trip Records
- **Période** : janvier 2024 → mars 2025
- **Volume brut** : 44 644 895 lignes après nettoyage dates

---

## 2. Anomalies détectées

| Anomalie | Nombre | % | Action |
|----------|--------|---|--------|
| `passenger_count` NULL | 4 631 381 | 10.4% | Exclure |
| `trip_distance` ≤ 0 | 867 198 | 1.9% | Exclure |
| `fare_amount` < 0 | 6 | 0.001% | Exclure |
| Durée négative | 15 561 | 0.03% | Exclure |
| Durée > 24h | 236 | 0.001% | Exclure |

**Observation** : les lignes avec `payment_type = 0` (4 631 381)
correspondent aux mêmes lignes avec `passenger_count` NULL —
probablement des courses non finalisées ou mal enregistrées.

---

## 3. Règles de nettoyage appliquées

- `passenger_count` NOT NULL, > 0 et <= 6
- `trip_distance` > 0
- `fare_amount` >= 0 et `total_amount` >= 0
- Durée trajet > 0 et <= 24 heures
- `tpep_dropoff_datetime` > `tpep_pickup_datetime`

Implémentées dans : `sql/07_create_staging_trips.sql`

---

## 4. Résultats après nettoyage

| Étape | Volume | Évolution |
|-------|--------|-----------|
| Après nettoyage dates (01-03-2025) | 44 644 946 | - |
| Après exclusion anomalies | 39 130 564 | -5 514 382 lignes |
| Taux de conservation | 87.65% | Excellent |

Lignes valides et prêtes pour STAGING.

---

## 5. Taux de rétention final

- **Entrée** : 44 644 946 lignes (nettoyées de dates aberrantes)
- **Sortie** : 39 130 564 lignes conformes
- **Taux de rétention** : 87.65%
- **Perte acceptée** : 12.35% (données non valides)

## Anomalie supplémentaire détectée post-staging

Février et mars 2025 : 2 lignes chacun avec des durées aberrantes
(ex: 82 minutes pour 2,45 km). Supprimées de STAGING.
Volume final STG_TRIPS après nettoyage complet : à recalculer.