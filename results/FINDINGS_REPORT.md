# Olist E-Commerce Customer Analytics — Findings Report

**Status:** In progress. Q5 results verified from Oracle SQL Developer screenshot dated November 10, 2026. All other business-query results remain pending.

## Objective

Explore whether late delivery is associated with lower customer review scores and quantify repeat purchasing, regional delivery differences, and category revenue.

## Reproducibility checklist

- [x] Run `01_schema.sql` and `02_staging_tables.sql`
- [x] Import eight prepared CSV datasets into staging tables (counts reconciled in the data quality report)
- [x] Run `03_load.sql`; final-table row counts reconciled against staging-derived expectations
- [x] Check orphaned foreign keys and unexpected nulls (see `data_quality_report.md`; eight delivered-status records missing delivery dates flagged)
- [ ] Execute all ten queries from `04_queries.sql`
- [ ] Export result CSVs and capture SQL Developer screenshots
- [ ] Record the query date, Oracle version, and limitations

## Q5: Late deliveries and review scores — verified

**Question:** Are customer review scores lower for orders delivered later than their estimated delivery dates?

**Method:** Analyze orders with `status = 'delivered'`, a non-null actual delivery timestamp, and a non-null estimated delivery timestamp. Aggregate any multiple reviews for the same order into one mean review score before comparing late versus on-time orders. SQL: [`oracle/04_queries.sql`](../oracle/04_queries.sql), Q5.

| Delivery status | Orders analyzed | Average review score (1–5) |
|---|---:|---:|
| Late | 7,661 | 2.57 |
| On Time | 88,163 | 4.29 |
| **Total** | **95,824** | **1.72** |

**Finding:** The average score for on-time orders was **1.72 points higher** than for late orders (4.29 − 2.57, based on rounded group means). **7,661 / 95,824 ≈ 7.99%** of reviewed delivered orders in this comparison were late. This is an association; the analysis does **not** establish that late delivery causes lower review scores.

**Scope:** Results exclude delivered orders without a usable actual delivery date, orders without a review, and non-delivered statuses. The denominator **95,824** is the population of reviewed delivered orders that met the query filters, not the entire orders dataset. An order with multiple review rows contributes one observation through its average review score.

**Evidence:** Project owner's Oracle SQL Developer screenshot dated November 10, 2026; `Olist_Project` connection, `Q5.sql` worksheet. Values are rounded to two decimals by the executed query.

**Potential business implication (hypothesis):** Improving delivery reliability may align with improved customer satisfaction. Further analysis should control for factors such as state, seller, and product category before making causal or predictive claims.

## Q6: Repeat customers

**Question:** What percentage of unique customers have more than one order?

| Unique customers | Repeat customers | Repeat rate |
|---:|---:|---:|
| Pending | Pending | Pending |

**Interpretation:** Pending verified results. The observation window is limited to 2016–2018.

## Other analyses

| Query | Business question | Verified output |
|---|---|---|
| Q1 | Top categories by revenue | Pending |
| Q2 | Monthly orders and revenue | Pending |
| Q3 | Order status breakdown | Pending |
| Q4 | Late delivery by state | Pending |
| Q7 | Top sellers and reviews | Pending |
| Q8 | Payment mix | Pending |
| Q9 | Average delivery time by state | Pending |
| Q10 | Lowest-rated categories | Pending |

## Business recommendations

To be written only after checking actual query outputs. Potential areas to investigate include delivery reliability, customer experience, and seller performance.

## Data source

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
