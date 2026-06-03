import os
import snowflake.connector
from pathlib import Path

# Détection de l'environnement (Local ou Streamlit Cloud)
try:
    import streamlit as st
    HAS_STREAMLIT = True
except ImportError:
    HAS_STREAMLIT = False

# Charger le fichier .env UNIQUEMENT en local
if not HAS_STREAMLIT:
    from dotenv import load_dotenv
    env_path = Path(__file__).parent.parent / '.env'
    load_dotenv(dotenv_path=env_path)

def get_secret(key):
    """Récupère un secret : priorité à Streamlit Cloud, sinon variables d'environnement locales"""
    if HAS_STREAMLIT:
        return st.secrets.get(key)
    return os.getenv(key)

def get_snowflake_connection():
    """Établit une connexion à Snowflake de manière sécurisée"""
    return snowflake.connector.connect(
        account=get_secret("SNOWFLAKE_ACCOUNT"),
        user=get_secret("SNOWFLAKE_USER"),
        password=get_secret("SNOWFLAKE_PASSWORD"),
        warehouse=get_secret("SNOWFLAKE_WAREHOUSE"),
        database=get_secret("SNOWFLAKE_DATABASE"),
        role=get_secret("SNOWFLAKE_ROLE")
    )

def execute_query(query):
    """Exécute une requête SQL et retourne un DataFrame pandas"""
    import pandas as pd
    conn = get_snowflake_connection()
    try:
        df = pd.read_sql(query, conn)
        return df
    finally:
        conn.close()