# Olist E-Commerce Database — Data Quality Report

**Project:** E-Commerce Orders Database & Customer Analytics  
**Database:** Oracle Autonomous Database / SQL Developer  
**Status:** Validation run reported by project owner; results pending documentation and independent review

## Purpose

Before drawing conclusions about customer satisfaction, late deliveries, and repeat purchases, check that the relational database loaded correctly and that important business fields are usable.

The reproducible checks are in [`oracle/04_data_validation.sql`](../oracle/04_data_validation.sql). This report must be filled with actual SQL Developer outputs; no result should be marked verified until confirmed.

## 1. Row counts

| Final table | Actual rows | Source / expected rows | Status |
|---|---:|---:|---|
| LOCATIONS | Pending | 15,078 (previous reference) | Pending |
| CUSTOMERS | Pending | 96,096 (previous reference) | Pending |
| SELLERS | Pending | 3,095 (previous reference) | Pending |
| PRODUCT_CATEGORIES | Pending | 73 (previous reference) | Pending |
| PRODUCTS | Pending | 32,951 (previous reference) | Pending |
| ORDERS | Pending | 99,441 (source rows) | Pending |
| ORDER_ITEMS | Pending | 112,650 (source rows) | Pending |
| ORDER_PAYMENTS | Pending | 103,886 (source rows) | Pending |
| ORDER_REVIEWS | Pending | 99,224 (source rows) | Pending |

**Note:** Customer rows in the final table are deduplicated by `customer_unique_id`, so a different final count from the raw customer CSV is expected. Confirm these reference counts against your own imported files.

## 2. Primary keys and duplicates

Record whether all nine final tables have the required primary key constraints enabled and validated.

- Primary-key constraints: **Pending**
- Duplicate `orders.order_id` groups: **Pending**
- Findings: **Pending**

## 3. Foreign keys and orphan rows

| Check | Actual count | Expected |
|---|---:|---:|
| Order items without matching order | Pending | 0 |
| Order payments without matching order | Pending | 0 |
| Order reviews without matching order | Pending | 0 |

List any missing or disabled constraints: **Pending**

## 4. Missing and invalid values

| Quality check | Actual result |
|---|---:|
| Orders missing customer ID | Pending |
| Orders missing purchase timestamp | Pending |
| Orders missing actual delivery timestamp | Pending |
| Orders missing estimated delivery timestamp | Pending |
| Reviews missing score | Pending |
| Review scores outside 1–5 | Pending |

Some missing delivery timestamps are legitimate for cancelled or undelivered orders. Report missingness by order status rather than treating all missing values as errors.

## 5. Limitations

- The historical dataset covers 2016–2018 and one marketplace.
- The normalized customer table keeps one ZIP prefix per unique customer; that may not describe their location at the time of every order.
- Foreign-key checks alone cannot establish that every source CSV row was imported.
- Missing review scores, delivery timestamps, and duplicate review IDs must be considered when interpreting analyses.

## 6. Next steps

1. Run `oracle/04_data_validation.sql` using the project schema.
2. Paste the actual numerical outputs into this report.
3. Investigate any discrepancies.
4. Record whether the database is ready for the ten business-analysis queries.
