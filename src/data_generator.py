import pandas as pd
import random
import dateutil.relativedelta
from faker import Faker
import datetime

if __name__ == '__main__':

    # Initialize Faker
    fake = Faker()

    def generate_leads() -> pd.DataFrame:

        # Create an empty data variable and populate with synthetic data
        data = []

        for _ in range(random.randint(20_000, 30_000)):
            data.append({

                'lead_id': random.randint(100_000, 300_000),
                'lead_name': fake.name(),
                'lead_phone': fake.phone_number(),
                'lead_source': random.choice(['Facebook', 'Paid Google', 'Organic Search', 'Affiliates', 'Paid Bing']),
                'lead_creation_datetime': fake.date_time_between(start_date=datetime.date(2024, 1, 1), end_date=datetime.date(2024, 6, 1)),
                'valid_lead': random.choice([0, 1])

            })

        df = pd.DataFrame(data).drop_duplicates(subset='lead_id')

        return df

    def generate_clients(df: pd.DataFrame) -> pd.DataFrame:

        # Generate a sample of the leads dataframe
        df_valid_leads = df[df['valid_lead'] == 1] 
        df_clients = df_valid_leads.sample(random.randint(8_000, 10_000))

        # Select columns
        df_clients = df_clients[['lead_id', 'lead_creation_datetime']]

        # Generate client_creation_datetime and client id for each row
        df_clients['client_id'] = df_clients.apply(lambda _: random.randint(50_000, 80_000), axis=1)
        df_clients['client_creation_datetime'] = df_clients['lead_creation_datetime'] \
                                                .apply(lambda x: fake.date_time_between(start_date=x, end_date=datetime.datetime(2024, 6, 1)))

        # Drop the lead_creation_datetime column
        df_clients.drop(columns='lead_creation_datetime', inplace = True)
        df_clients.drop_duplicates(subset='client_id', inplace=True)

        return df_clients

    def generate_orders(df: pd.DataFrame) -> pd.DataFrame:

        # Generate a sample of the clients dataframe 
        df_orders = df.sample(random.randint(3_000, 6_000))

        # Randomly multiply each row by 1, 2, 3 or 4 to create orders for some clients
        df_orders = df_orders.loc[df_orders.index.repeat(random.choices([1, 2, 3, 4], k=len(df_orders)))]

        # Generate order_creation_datetime and order id for each row
        df_orders['order_id'] = df_orders.apply(lambda _: random.randint(10_000, 50_000), axis=1)
        df_orders['order_creation_datetime'] = df_orders['client_creation_datetime'] \
                                                .apply(lambda x: fake.date_time_between(start_date=x, end_date=datetime.datetime(2024, 6, 1)))

        # Generate the amount column
        df_orders['order_amount'] = round(df_orders.apply(lambda _: random.uniform(800, 1500), axis=1), 2)

        # Drop unnecessary columns and get rid of duplicated order ids
        df_orders.drop(columns=['client_creation_datetime', 'lead_id'], inplace=True)
        df_orders.drop_duplicates(subset='order_id', inplace=True)

        return df_orders