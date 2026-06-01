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
*(à compléter après création de STAGING.STG_TRIPS)*

---

## 4. Résultats après nettoyage
*(à compléter après création de STAGING.STG_TRIPS)*

---

## 5. Taux de rétention final
*(à compléter)*
