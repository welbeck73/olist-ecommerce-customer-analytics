# Olist E-Commerce Orders Database & Customer Analytics

**Status: SQL database and validation complete; business analysis in progress | Oracle SQL Developer · SQL · Relational Data Modeling**

A database management and analytics portfolio project using the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering approximately 100,000 orders from 2016–2018.

## Business questions

- Do late deliveries receive lower customer review scores?
- How often do customers make repeat purchases?
- Which product categories generate the most revenue?
- How do delivery performance and satisfaction vary across regions?

## Verified findings and visualizations

These visuals use results executed in Oracle SQL Developer and documented in the [findings report](results/FINDINGS_REPORT.md). They are descriptive analyses of the historical Olist data, not causal or predictive estimates.

### Top product categories by item-price sales

![Top ten product categories ranked by delivered-order item-price sales](visualizations/top_categories.svg)

### Delivery timeliness and customer review scores

![Average customer review score for on-time and late delivered orders](visualizations/delivery_reviews.svg)

### Observed repeat-purchase rate

![3.12 percent of unique customers placed more than one order](visualizations/repeat_purchases.svg)

## Project approach

1. Design an entity-relationship diagram and normalized (3NF) Oracle schema.
2. Prepare source CSVs and import them into staging tables.
3. Transform and validate data in relational tables.
4. Run documented SQL queries to investigate customer and delivery outcomes.
5. Summarize results, limitations, and business recommendations.

## Portfolio artifacts

- [Entity relationship diagram](diagrams/ER_DIAGRAM.md) — GitHub-rendered Mermaid diagram based on the Oracle schema
- [Findings report](results/FINDINGS_REPORT.md) — verified Q1, Q5 and Q6 results plus pending questions
- [Data quality report](results/data_quality_report.md) — source-to-final reconciliation and integrity checks
- [Charts](visualizations/) — SVG visualizations generated from verified SQL results

## Repository structure

- `oracle/01_schema.sql` — relational tables, keys, and indexes
- `oracle/02_staging_tables.sql` — CSV import staging tables
- `oracle/03_load.sql` — transformation and loading queries
- `oracle/04_queries.sql` — ten business analysis queries
- `oracle/04_data_validation.sql` — reproducible validation queries
- `scripts/prepare_csv_for_oracle.py` — CSV cleanup utility
- `diagrams/ER_DIAGRAM.md` — documented ER diagram
- `results/` — verified findings and validation reporting
- `visualizations/` — three charts based on verified Oracle query results

## Running the Oracle version

1. Download the dataset from the Kaggle link above. The raw datasets are not included in this repository.
2. Place the eight required CSV files in `data/` (geolocation is not required).
3. Run `python scripts/prepare_csv_for_oracle.py` after installing pandas.
4. Run `oracle/01_schema.sql`, then `oracle/02_staging_tables.sql` in Oracle SQL Developer.
5. Import the prepared CSV files from `data/oracle/` into the corresponding staging tables using SQL Developer's Import Data wizard.
6. Run `oracle/03_load.sql`, inspect row counts, and then execute queries in `oracle/04_queries.sql`.

**Validation note:** The project owner successfully executed the Oracle load and validation checks. Actual final-table counts match staging-derived expectations for all nine tables; nine primary keys and nine foreign keys are enabled and validated. Eight delivered-status orders have missing actual delivery timestamps and remain documented as a data quality caveat. See [data quality report](results/data_quality_report.md).

## Skills demonstrated

SQL joins, aggregations, window functions, data normalization, ER modeling, data preparation, customer analytics, and business storytelling.

## Data attribution

Dataset: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Check the dataset's license before redistributing data.
