# Olist E-Commerce Database — Data Quality Report

**Project:** E-Commerce Orders Database & Customer Analytics  
**Database:** Oracle Autonomous Database / SQL Developer  
**Status:** All nine final-table counts verified against reference counts from the project owner's SQL Developer script output on November 10, 2026; all nine primary-key constraints and nine foreign-key constraints verified enabled and validated; all three orphan-record checks returned zero; order-field missing-value counts documented; review-score minimum/maximum and missing count documented; review-score validation complete; delivery-status check pending

## Purpose

Before drawing conclusions about customer satisfaction, late deliveries, and repeat purchases, check that the relational database loaded correctly and that important business fields are usable.

The reproducible checks are in [`oracle/04_data_validation.sql`](../oracle/04_data_validation.sql). The row-count section records actual SQL Developer results supplied by the project owner on November 10, 2026. Primary-key, foreign-key, and orphan-record results are also verified from the project owner's SQL Developer screenshots. Missing-value and remaining checks are pending and should only be marked verified after their outputs are reviewed.

## 1. Row counts

| Final table | Actual rows | Source / expected rows | Status |
|---|---:|---:|---|
| LOCATIONS | 15,078 | 15,078 (previous reference) | MATCH |
| CUSTOMERS | 96,096 | 96,096 (previous reference) | MATCH |
| SELLERS | 3,095 | 3,095 (previous reference) | MATCH |
| PRODUCT_CATEGORIES | 73 | 73 (previous reference) | MATCH |
| PRODUCTS | 32,951 | 32,951 (previous reference) | MATCH |
| ORDERS | 99,441 | 99,441 (source rows) | MATCH |
| ORDER_ITEMS | 112,650 | 112,650 (source rows) | MATCH |
| ORDER_PAYMENTS | 103,886 | 103,886 (source rows) | MATCH |
| ORDER_REVIEWS | 99,224 | 99,224 (source rows) | MATCH |

**Row-count result:** 9/9 final-table counts match the stated reference counts. This confirms counts, not full record-level correctness or completeness.

**Note:** Customer rows in the final table are deduplicated by `customer_unique_id`, so a different final count from the raw customer CSV is expected. Confirm these reference counts against your own imported files.

## 2. Primary keys and duplicates

**Primary-key validation: PASS (9/9).** SQL Developer results from November 10, 2026 show one primary-key constraint per final table. All nine constraints have `STATUS = ENABLED` and `VALIDATED = VALIDATED`.

| Final table | Primary-key column(s) | Status | Validation |
|---|---|---|---|
| CUSTOMERS | CUSTOMER_UNIQUE_ID | ENABLED | VALIDATED |
| LOCATIONS | ZIP_PREFIX | ENABLED | VALIDATED |
| ORDERS | ORDER_ID | ENABLED | VALIDATED |
| ORDER_ITEMS | ORDER_ID, ORDER_ITEM_ID | ENABLED | VALIDATED |
| ORDER_PAYMENTS | ORDER_ID, PAYMENT_SEQUENTIAL | ENABLED | VALIDATED |
| ORDER_REVIEWS | REVIEW_KEY | ENABLED | VALIDATED |
| PRODUCTS | PRODUCT_ID | ENABLED | VALIDATED |
| PRODUCT_CATEGORIES | CATEGORY_NAME | ENABLED | VALIDATED |
| SELLERS | SELLER_ID | ENABLED | VALIDATED |

**Interpretation:** Oracle confirms that the declared primary-key constraints are enabled and validated, which enforces uniqueness and non-nullness of the listed primary-key columns. This does not establish that unrelated fields are free of duplicates or missing values.

- Duplicate `orders.order_id` groups: **0 — PASS** (verified from SQL Developer screenshot on November 10, 2026; query groups `ORDERS` by `ORDER_ID` and counts groups with more than one row).
- Foreign-key and orphan-record checks: **PASS** (see Section 3)

**Evidence:** Project owner's screenshot of SQL Developer query results, November 10, 2026.

## 3. Foreign keys and orphan rows

**Foreign-key validation: PASS (9/9).** Oracle SQL Developer reported nine foreign-key constraints, all `ENABLED` and `VALIDATED`, on November 10, 2026.

| Child table | Parent table | Status | Validation |
|---|---|---|---|
| CUSTOMERS | LOCATIONS | ENABLED | VALIDATED |
| ORDERS | CUSTOMERS | ENABLED | VALIDATED |
| ORDER_ITEMS | ORDERS | ENABLED | VALIDATED |
| ORDER_ITEMS | PRODUCTS | ENABLED | VALIDATED |
| ORDER_ITEMS | SELLERS | ENABLED | VALIDATED |
| ORDER_PAYMENTS | ORDERS | ENABLED | VALIDATED |
| ORDER_REVIEWS | ORDERS | ENABLED | VALIDATED |
| PRODUCTS | PRODUCT_CATEGORIES | ENABLED | VALIDATED |
| SELLERS | LOCATIONS | ENABLED | VALIDATED |

**Orphan-record checks: PASS (3/3).** Separate left-join checks confirmed the following counts:

| Check | Actual count | Expected | Result |
|---|---:|---:|---|
| Order items without matching order | 0 | 0 | PASS |
| Order payments without matching order | 0 | 0 | PASS |
| Order reviews without matching order | 0 | 0 | PASS |

**Interpretation:** The displayed foreign-key constraints are enforced and validated, and no unmatched order references were found in these three child tables. This verifies referential integrity for the checked relationships, not full source-to-target record-level completeness.

**Evidence:** SQL Developer screenshots supplied by the project owner, November 10, 2026.

## 4. Missing and invalid values

| Quality check | Actual result |
|---|---:|
| Orders missing customer ID | 0 |
| Orders missing purchase timestamp | 0 |
| Orders missing actual delivery timestamp | 2,965 |
| Orders missing estimated delivery timestamp | 0 |
| Reviews missing score | 0 |
| Review scores outside 1–5 | 0 — PASS |

**Order-field validation (November 10, 2026):** SQL Developer reported **99,441 total orders**, **0** missing customer IDs, **0** missing purchase timestamps, **2,965** missing actual delivery timestamps, and **0** missing estimated delivery timestamps. Thus **96,476** orders have a populated actual delivery timestamp, and the missing actual-delivery share is **2.98%** (2,965 / 99,441 × 100, rounded). These are observed missing values, not yet classified as data errors.

**Review-score validation (November 10, 2026):** SQL Developer screenshot shows **99,224 total reviews**, **0 missing review scores**, minimum score **1**, and maximum score **5**. A separate SQL query confirmed **0 review scores outside 1–5**. Together with zero missing scores, this confirms all 99,224 review scores satisfy the expected range. Evidence: project owner's SQL Developer screenshot, November 10, 2026.

Some missing delivery timestamps are legitimate for cancelled or undelivered orders. Report missingness by order status rather than treating all missing values as errors. The order-status breakdown of the 2,965 missing actual delivery timestamps remains **Pending**. Review-score checks also remain **Pending**.

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
