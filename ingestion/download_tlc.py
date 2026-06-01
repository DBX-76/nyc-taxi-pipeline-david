"""
NYC TLC — Téléchargement Yellow Taxi 2024 + upload Snowflake
"""

import os
import requests
from pathlib import Path
from tqdm import tqdm
from dotenv import load_dotenv
import snowflake.connector

load_dotenv()

# ── Config ─────────────────────────────────────────────────────────────────────

SNOWFLAKE_CONFIG = {
    "account":   os.getenv("SNOWFLAKE_ACCOUNT"),
    "user":      os.getenv("SNOWFLAKE_USER"),
    "password":  os.getenv("SNOWFLAKE_PASSWORD"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE", "NYC_TAXI_WH"),
    "database":  os.getenv("SNOWFLAKE_DATABASE",  "NYC_TAXI"),
    "schema":    "RAW",
    "role":      os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
}

DATA_DIR = Path("data/raw")
DATA_DIR.mkdir(parents=True, exist_ok=True)

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"

# Yellow Taxi uniquement — jan 2024 à jan 2025
FICHIERS = [
    f"yellow_tripdata_2024-{mois:02d}.parquet"
    for mois in range(1, 13)
] + ["yellow_tripdata_2025-01.parquet"]


# ── Fonctions ──────────────────────────────────────────────────────────────────

def telecharger(nom: str) -> Path | None:
    chemin = DATA_DIR / nom
    if chemin.exists():
        print(f"  [skip] {nom} déjà présent")
        return chemin

    url = f"{BASE_URL}/{nom}"
    print(f"  [dl]   {nom}")
    r = requests.get(url, stream=True, timeout=60)

    if r.status_code == 404:
        print(f"  [warn] {nom} introuvable (pas encore publié ?)")
        return None

    r.raise_for_status()
    taille = int(r.headers.get("content-length", 0))

    with open(chemin, "wb") as f, tqdm(
        total=taille, unit="B", unit_scale=True, desc=nom, leave=False
    ) as bar:
        for chunk in r.iter_content(8192):
            f.write(chunk)
            bar.update(len(chunk))

    return chemin


def uploader(chemin: Path, conn) -> None:
    if chemin is None:
        return
    print(f"  [up]   {chemin.name} → @NYC_TAXI_STAGE")
    cur = conn.cursor()
    cur.execute(
        f"PUT file://{chemin.resolve()} @RAW.NYC_TAXI_STAGE "
        f"AUTO_COMPRESS=FALSE OVERWRITE=FALSE"
    )
    for row in cur.fetchall():
        print(f"         {row[0]} → {row[6]}")
    cur.close()


def copy_into(conn) -> None:
    print("\n[COPY INTO] Yellow trips...")
    cur = conn.cursor()
    cur.execute("""
        COPY INTO RAW.YELLOW_TRIPS
        FROM (
            SELECT
                $1:VendorID::NUMBER,
                $1:tpep_pickup_datetime::TIMESTAMP_NTZ,
                $1:tpep_dropoff_datetime::TIMESTAMP_NTZ,
                $1:passenger_count::NUMBER,
                $1:trip_distance::FLOAT,
                $1:RatecodeID::NUMBER,
                $1:store_and_fwd_flag::VARCHAR,
                $1:PULocationID::NUMBER,
                $1:DOLocationID::NUMBER,
                $1:payment_type::NUMBER,
                $1:fare_amount::FLOAT,
                $1:extra::FLOAT,
                $1:mta_tax::FLOAT,
                $1:tip_amount::FLOAT,
                $1:tolls_amount::FLOAT,
                $1:improvement_surcharge::FLOAT,
                $1:total_amount::FLOAT,
                $1:congestion_surcharge::FLOAT,
                $1:airport_fee::FLOAT
            FROM @RAW.NYC_TAXI_STAGE
        )
        FILE_FORMAT = (TYPE = 'PARQUET')
        PATTERN     = '.*yellow.*\\.parquet.*'
        ON_ERROR    = 'CONTINUE'
    """)
    for row in cur.fetchall():
        print(f"  {row[0]} : {row[1]} lignes chargées, {row[2]} erreurs")
    cur.close()


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("=== Téléchargement fichiers TLC ===")
    chemins = [telecharger(nom) for nom in FICHIERS]

    print(f"\n=== Connexion Snowflake ===")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    print("  OK")

    print("\n=== Upload vers Snowflake Stage ===")
    for chemin in chemins:
        uploader(chemin, conn)

    copy_into(conn)

    print("\n=== Contrôle final ===")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM RAW.YELLOW_TRIPS")
    count = cur.fetchone()[0]
    print(f"  YELLOW_TRIPS : {count:,} lignes")
    cur.close()
    conn.close()
    print("\nTerminé ✓")


if __name__ == "__main__":
    main()