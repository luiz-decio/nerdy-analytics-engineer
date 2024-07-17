# Nerdy Analytics Engineer Take-Home Assignment

This repository contains the implementation for the Analytics Engineer take-home assignment, which involves generating synthetic data, setting up a PostgreSQL database using Docker, and querying the data to produce a report.

### If you prefer to jump straight to the results, go to the [docs folder](/docs) for the [query](/docs/query.sql), [CSV file](/docs/results.csv) with example results, and the original [question file](/docs/"Data_Analyst_HW.docx)!

## Project Structure

- `data_generator.py`: Python scriptwith functions to generate synthetic data for the `LEADS`, `CLIENTS`, and `ORDERS` tables.
- `docker-compose.yaml`: Docker Compose file to set up PostgreSQL and PGAdmin for data loading and querying.
- `extract_load.py`: Script to generate synthetic data and load it into the PostgreSQL database.

## Setup Instructions

### Prerequisites

Ensure you have the following installed on your system:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Python 3.x](https://www.python.org/)

### Step 1: Build Docker Image

Run the `docker-compose.yaml` file to setup Docker Database and PgAdmin.

```bash
docker-compose up
```

### Step 2: Generate Synthetic Data in the Database

Run the `extract_load.py` script to create synthetic data for the database tables.

```bash
python src/extract_load.py
```

### Step 3: Run the query to see the results

The [query](/docs/query.sql) can be found in the docs folder! The results will be something like this:

![Alt](/docs/pgadmin.png)

To improve query performance you can create indexes in the columns used in aggregation and sorting operations, like so:

```sql
CREATE INDEX idx_orders_order_creation_datetime
ON ORDERS (order_creation_datetime);

CREATE INDEX idx_clients_client_id
ON CLIENTS (client_id);

CREATE INDEX idx_orders_client_id_order_creation_datetime
ON ORDERS (client_id, order_creation_datetime);
```
