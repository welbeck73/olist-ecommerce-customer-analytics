# Olist E-Commerce Customer Analytics — Findings Report

**Status:** Awaiting verified Oracle SQL Developer outputs. No results below should be interpreted as executed findings.

## Objective

Explore whether late delivery is associated with lower customer review scores and quantify repeat purchasing, regional delivery differences, and category revenue.

## Reproducibility checklist

- [ ] Run `01_schema.sql` and `02_staging_tables.sql`
- [ ] Import all eight prepared CSV files into staging tables
- [ ] Run `03_load.sql`; record row counts and errors
- [ ] Check orphaned foreign keys and unexpected nulls
- [ ] Execute all ten queries from `04_queries.sql`
- [ ] Export result CSVs and capture SQL Developer screenshots
- [ ] Record the query date, Oracle version, and limitations

## Q5: Late deliveries and review scores

**Question:** Are reviews for late deliveries lower than reviews for on-time deliveries?

**Method:** Join delivered orders with reviews; compare the delivery timestamp to the estimated delivery timestamp; aggregate review counts and mean scores by delivery category.

| Delivery status | Review count | Average score |
|---|---:|---:|
| On time | Pending | Pending |
| Late | Pending | Pending |

**Interpretation:** Pending verified results. A difference would show an association, not establish causality.

**Limitations:** Review records may not be one-to-one with orders; late delivery may be correlated with seller, product, and location factors.

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
