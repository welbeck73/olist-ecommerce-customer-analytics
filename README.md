# Olist E-Commerce Orders Database & Customer Analytics

**Status: In progress | Oracle SQL Developer · SQL · Python · Relational Data Modeling**

A database management and analytics portfolio project using the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering approximately 100,000 orders from 2016–2018.

## Business questions

- Do late deliveries receive lower customer review scores?
- How often do customers make repeat purchases?
- Which product categories generate the most revenue?
- How do delivery performance and satisfaction vary across regions?

## Project approach

1. Design an entity-relationship diagram and normalized (3NF) Oracle schema.
2. Prepare source CSVs and import them into staging tables.
3. Transform and validate data in relational tables.
4. Run documented SQL queries to investigate customer and delivery outcomes.
5. Summarize results, limitations, and business recommendations.

## Repository structure

- `oracle/01_schema.sql` — relational tables, keys, and indexes
- `oracle/02_staging_tables.sql` — CSV import staging tables
- `oracle/03_load.sql` — transformation and loading queries
- `oracle/04_queries.sql` — ten business analysis queries
- `scripts/prepare_csv_for_oracle.py` — CSV cleanup utility
- `diagrams/` — ER diagram (to be added)
- `results/` — verified query output and interpretation (to be added)

## Running the Oracle version

1. Download the dataset from the Kaggle link above. The raw datasets are not included in this repository.
2. Place the eight required CSV files in `data/` (geolocation is not required).
3. Run `python scripts/prepare_csv_for_oracle.py` after installing pandas.
4. Run `oracle/01_schema.sql`, then `oracle/02_staging_tables.sql` in Oracle SQL Developer.
5. Import the prepared CSV files from `data/oracle/` into the corresponding staging tables using SQL Developer's Import Data wizard.
6. Run `oracle/03_load.sql`, inspect row counts, and then execute queries in `oracle/04_queries.sql`.

**Validation note:** The SQL scripts have not yet been confirmed as successfully executed on a live Oracle database. Any expected results should be treated as provisional until reproduced and verified.

## Skills demonstrated

SQL joins, aggregations, window functions, data normalization, ER modeling, data preparation, customer analytics, and business storytelling.

## Data attribution

Dataset: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Check the dataset's license before redistributing data.
