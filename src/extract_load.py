import pandas as pd
import os
from sqlalchemy import create_engine
from dotenv import load_dotenv
from src.data_generator import generate_leads, generate_clients, generate_orders


load_dotenv()

# Import environment variables for Postgres
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")
POSTGRES_DB = os.getenv("POSTGRES_DB")

POSTGRES_DB_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

# Create the PostgreSQL engine
engine = create_engine(POSTGRES_DB_URL)


# Generate leads and save to Postgres
df_leads = generate_leads()
df_leads.to_sql('leads', engine, if_exists='replace', index=False)

# Generate clients and save to Postgres
df_clients = generate_clients(df_leads)
df_clients.to_sql('clients', engine, if_exists='replace', index=False)

# Generate orders and save to Postgres
df_orders = generate_orders(df_clients)
df_orders.to_sql('orders', engine, if_exists='replace', index=False)
