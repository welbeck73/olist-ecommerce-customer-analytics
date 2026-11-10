# Olist E-Commerce Customer Analytics — Findings Report

**Status:** In progress. Q5 and Q6 results verified from Oracle SQL Developer screenshots dated November 10, 2026. Other business-query results remain pending.

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

## Q6 — Repeat Customer Behavior

**Business Question:** What percentage of unique Olist customers placed more than one order in the observed dataset?

**Methodology:** Group orders by `customer_unique_id` and count distinct `order_id` values per customer. Count a customer as a repeat customer if they placed more than one distinct order. Divide the repeat-customer count by the number of customers represented in the orders table. The reproducible query is [Q6 in `oracle/04_queries.sql`](../oracle/04_queries.sql).

| Total unique customers | Repeat customers (2+ orders) | Customers with 1 order | Observed repeat-purchase rate |
|---:|---:|---:|---:|
| 96,096 | 2,997 | 93,099 | **3.12%** |

**Key Finding:** **2,997 out of 96,096** unique customers placed more than one order (**2,997 ÷ 96,096 × 100 ≈ 3.12%**). The other **93,099** customers placed one order in the recorded period.

**Business Implications:** Repeat purchases were uncommon within the data's observation window. Investigating repeat behavior by customer cohort or product category may help identify patterns, but no specific retention improvement is established by this descriptive result.

**Limitations:** This is the *observed repeat-purchase rate*, not a lifetime customer retention rate. The dataset has a limited historical window (2016–2018), and customers near the end of the period have less time to make another purchase. The measure counts orders, not purchased items, and does not establish why customers did or did not return.

**Verification:** Values transcribed from the project owner's Oracle SQL Developer screenshot dated November 10, 2026; Q6 query results.



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
