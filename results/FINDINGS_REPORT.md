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

## Q5 — Relationship Between Delivery Performance and Customer Satisfaction

**Business Question:** Do orders delivered later than their estimated delivery dates receive lower customer review scores?

**Methodology:** Using Oracle SQL, delivered orders were classified as either late or on time by comparing their actual delivery timestamps with their estimated delivery timestamps. Orders without the required delivery dates or customer reviews were excluded. For orders with multiple reviews, the review scores were averaged to ensure each order contributed only once to the analysis. The reproducible query is [Q5 in `oracle/04_queries.sql`](../oracle/04_queries.sql).

**Results:** A total of **95,824 orders** were analyzed.

| Delivery status | Orders analyzed | Average review score (1–5) |
|---|---:|---:|
| Late | 7,661 | 2.57 |
| On Time | 88,163 | 4.29 |
| **Total** | **95,824** | **Not calculated in this query** |

**Key Finding:** On-time deliveries received an average review score **1.72 points higher** than late deliveries, based on the rounded group averages (**4.29 − 2.57 = 1.72**). Approximately **7.99%** of the included orders were late (**7,661 ÷ 95,824 × 100**).

**Business Implications:** The findings indicate a strong descriptive association between delivery timeliness and customer satisfaction. Delivery reliability may be an important area for e-commerce businesses to investigate when developing strategies to improve customer experience. Further analysis should account for other potential influences before attributing rating differences to delivery performance.

**Limitations:** This analysis demonstrates an association rather than a causal relationship. Other factors, including product quality, seller performance, and geographic location, may influence review scores. Additionally, the results apply only to reviewed, delivered orders with usable actual and estimated delivery timestamps. Multiple reviews for an order are averaged into one observation. The 1.72-point difference is calculated from group averages rounded to two decimals rather than from unrounded values.

**Verification:** Results transcribed from the project owner's Oracle SQL Developer `Olist_Project` / `Q5.sql` screenshot dated November 10, 2026.

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
