Voici votre documentation consolidée et formatée en un seul fichier Markdown structuré et professionnel.

```markdown
# Dashboard Streamlit - Pipeline NYC Taxi

## Vue d'ensemble
Dashboard interactif permettant de visualiser les KPIs du pipeline NYC Taxi en temps réel, connecté directement à Snowflake.

## Architecture

```text
dashboard/
├── app.py              # Application Streamlit principale
├── snowflake_config.py # Configuration connexion Snowflake
└── requirements.txt    # Dépendances Python
```

## Fonctionnalités

### 1. KPIs principaux (4 cartes)
- **Total courses** : Nombre total de trajets (38.4M)
- **Revenu total** : Chiffre d'affaires global
- **Distance moyenne** : Moyenne des distances parcourues
- **Pourboire moyen** : Pourcentage moyen de pourboires

### 2. Visualisations interactives
- **Évolution mensuelle** : Graphique linéaire du nombre de courses par mois (2024-2025)
- **Répartition horaire** : Histogramme des courses par heure de la journée
- **Top 10 zones** : Barres horizontales des zones les plus demandées
- **Types de paiement** : Camembert de la répartition (carte, espèces, etc.)

### 3. Optimisation des performances
- **Cache intelligent** : Utilisation de `@st.cache_data(ttl=3600)` pour éviter de recharger les données à chaque rafraîchissement.
- **Premier chargement** : ~2-3 minutes (nécessaire pour le transfert de 38M lignes).
- **Chargements suivants** : Instantanés (données servies depuis le cache).

## Sécurité

Les identifiants Snowflake ne sont **jamais** présents dans le code source :
- Utilisation d'un fichier `.env` (ignoré par Git).
- Chargement des variables d'environnement via `python-dotenv`.
- Compatible avec **Streamlit Cloud** (gestion native des secrets).

## Lancement local

1. **Activer l'environnement virtuel**
   ```bash
   .venv\Scripts\Activate
   ```

2. **Se positionner dans le dossier dashboard**
   ```bash
   cd dashboard
   ```

3. **Lancer Streamlit**
   ```bash
   streamlit run app.py
   ```

Le dashboard s'ouvre automatiquement sur [http://localhost:8501](http://localhost:8501).
```