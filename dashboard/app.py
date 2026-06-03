import streamlit as st
import pandas as pd
import plotly.express as px
from snowflake_config import execute_query
import warnings

# Ignorer les warnings pandas/snowflake pour un affichage propre
warnings.filterwarnings('ignore')

# Configuration de la page
st.set_page_config(
    page_title="NYC Taxi Dashboard",
    page_icon="🚕",
    layout="wide"
)

# Titre explicite sur la période
st.title("🚕 NYC Taxi Pipeline Dashboard")
st.caption("Visualisation des KPIs Yellow Taxi - Période : Janvier 2024 à Janvier 2025")

# Chargement des données
@st.cache_data(ttl=3600)
def load_data():
    with st.spinner("Chargement des agrégats depuis Snowflake..."):
        kpi_monthly = execute_query("""
            SELECT 
                pickup_year, pickup_month,
                COUNT(*) as nb_courses,
                ROUND(AVG(trip_distance), 2) as distance_moyenne_km,
                ROUND(AVG(trip_duration_min), 2) as duree_moyenne_min,
                ROUND(AVG(total_amount), 2) as total_moyen,
                ROUND(AVG(tip_percentage), 2) as pourboire_moyen_pct,
                ROUND(SUM(total_amount), 2) as revenu_total
            FROM NYC_TAXI.PUBLIC_STAGING.STG_YELLOW_TRIPS
            GROUP BY pickup_year, pickup_month
            ORDER BY pickup_year, pickup_month
        """)
        
        kpi_hourly = execute_query("""
            SELECT 
                pickup_hour,
                COUNT(*) as nb_courses,
                ROUND(AVG(total_amount), 2) as total_moyen,
                ROUND(AVG(tip_percentage), 2) as pourboire_moyen_pct
            FROM NYC_TAXI.PUBLIC_STAGING.STG_YELLOW_TRIPS
            GROUP BY pickup_hour
            ORDER BY pickup_hour
        """)
        
        kpi_zones = execute_query("""
            SELECT 
                z.Zone, z.Borough,
                COUNT(*) as nb_courses,
                ROUND(SUM(t.total_amount), 2) as revenu_total
            FROM NYC_TAXI.PUBLIC_STAGING.STG_YELLOW_TRIPS t
            LEFT JOIN NYC_TAXI.RAW.TAXI_ZONES z ON t.PULocationID = z.LocationID
            GROUP BY z.Zone, z.Borough
            ORDER BY nb_courses DESC
            LIMIT 10
        """)
        
        kpi_payment = execute_query("""
            SELECT 
                CASE payment_type
                    WHEN 1 THEN 'Carte de crédit'
                    WHEN 2 THEN 'Espèces'
                    WHEN 3 THEN 'Pas de charge'
                    WHEN 4 THEN 'Litige'
                    WHEN 5 THEN 'Inconnu'
                END as payment_label,
                COUNT(*) as nb_courses
            FROM NYC_TAXI.PUBLIC_STAGING.STG_YELLOW_TRIPS
            GROUP BY payment_type, payment_label
            ORDER BY nb_courses DESC
        """)
        
        return kpi_monthly, kpi_hourly, kpi_zones, kpi_payment

# Exécution
kpi_monthly, kpi_hourly, kpi_zones, kpi_payment = load_data()

# 1. KPIs principaux (4 cartes en haut)
st.subheader(" Indicateurs clés de performance")
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Total des courses", f"{kpi_monthly['NB_COURSES'].sum():,.0f}")
with col2:
    st.metric("Revenu total", f"${kpi_monthly['REVENU_TOTAL'].sum():,.0f}")
with col3:
    st.metric("Distance moyenne", f"{kpi_monthly['DISTANCE_MOYENNE_KM'].mean():.2f} km")
with col4:
    st.metric("Pourboire moyen", f"{kpi_monthly['POURBOIRE_MOYEN_PCT'].mean():.1f}%")

# 2. Évolution mensuelle
st.subheader("📈 Évolution du volume mensuel")
fig_monthly = px.line(
    kpi_monthly,
    x='PICKUP_MONTH',
    y='NB_COURSES',
    color='PICKUP_YEAR',
    title="Nombre de courses par mois",
    markers=True
)
st.plotly_chart(fig_monthly, width='stretch')

# 3. Répartition horaire et Paiement
col_left, col_right = st.columns(2)

with col_left:
    st.subheader("🕐 Répartition horaire (Heure de pickup)")
    fig_hourly = px.bar(
        kpi_hourly,
        x='PICKUP_HOUR',
        y='NB_COURSES',
        title="Volume de courses par heure",
        labels={'PICKUP_HOUR': 'Heure', 'NB_COURSES': 'Courses'}
    )
    st.plotly_chart(fig_hourly, width='stretch')

with col_right:
    st.subheader("💳 Types de paiement")
    fig_payment = px.pie(
        kpi_payment,
        values='NB_COURSES',
        names='PAYMENT_LABEL',
        title="Répartition des méthodes de paiement"
    )
    st.plotly_chart(fig_payment, width='stretch')

# 4. Top 10 Zones
st.subheader("📍 Top 10 des zones de prise en charge")
fig_zones = px.bar(
    kpi_zones,
    x='NB_COURSES',
    y='ZONE',
    orientation='h',
    title="Les 10 zones les plus demandées",
    color='REVENU_TOTAL',
    color_continuous_scale='Viridis'
)
st.plotly_chart(fig_zones, width='stretch')

# Footer
st.markdown("---")
st.markdown("**Pipeline** : Python ➔ Snowflake  dbt ➔ GitHub Actions ➔ Streamlit")