import pandas as pd
import random
import dateutil.relativedelta
from faker import Faker
import datetime

# Initialize Faker
fake = Faker()

def generate_leads() -> pd.DataFrame:

    # Create an empty data variable and populate with synthetic data
    data = []

    for _ in range(random.randint(2000, 3000)):
        data.append({

            'lead_id': random.randint(100_000, 300_000),
            'lead_name': fake.name(),
            'lead_phone': fake.phone_number(),
            'lead_source': random.choice(['Facebook', 'Paid Google', 'Organic Search', 'Affiliates', 'Paid Bing']),
            'lead_creation_datetime': fake.date_time_between(start_date=datetime.date(2024, 1, 1), end_date=datetime.date(2024, 6, 1)),
            'valid_lead': random.choice([0, 1])

        })

    df = pd.DataFrame(data)

    return df

df_leads = generate_leads()

df_leads.sample(random.randint(500, 1000))

def generate_clients(df: pd.DataFrame) -> pd.DataFrame:
    
    # Create an empty data variable and populate with synthetic data
    data = []

    for _ in range(random.randint(500, 1000)):
        data.append({

            'client_id': random.randint(10_000, 80_000),
            'client_creation_datetime': fake.date_time_between(start_date=datetime.date(2024, 1, 1), end_date=datetime.date(2024, 6, 1)),

        })

