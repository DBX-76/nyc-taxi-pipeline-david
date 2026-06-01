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

| Étape | Lignes |
|-------|--------|
| RAW brut chargé | 44 644 946 |
| Suppression dates hors 2024-2025 | 44 644 895 |
| STAGING après règles qualité | 38 448 594 |
| Suppression résidus fév-mars 2025 | 38 448 590 |

## 5. Taux de rétention final

**86,1%** de rétention — 6,2M lignes exclues.
Données propres couvrant 13 mois : jan 2024 → jan 2025.

## 6. Chiffres clés

| KPI | Valeur |
|-----|--------|
| Total courses | 38 448 590 |
| Mois record | Octobre 2024 (3,3M courses) |
| Revenu total 2024 | ~1,03 milliard $ |
| Tarif moyen | ~19-20$ |
| Total moyen | ~27-30$ |
| % paiement carte | 83,95% |
| Zone la plus active | JFK Airport (1,99M courses) |
| Heure de pointe | 18h (2,76M courses) |

## Anomalie supplémentaire détectée post-staging

Février et mars 2025 : 2 lignes chacun avec des durées aberrantes
(ex: 82 minutes pour 2,45 km). Supprimées de STAGING.
Volume final STG_TRIPS après nettoyage complet : à recalculer.