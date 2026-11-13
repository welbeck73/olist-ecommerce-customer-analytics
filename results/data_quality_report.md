# Olist E-Commerce Database — Data Quality Report

**Project:** E-Commerce Orders Database & Customer Analytics  
**Database:** Oracle Autonomous Database / SQL Developer  
**Summary:** The nine final tables matched their transformation-aware expected row counts. Primary and foreign keys were enabled and validated, and the orphan-record and review-score checks passed. Eight orders marked `delivered` lack actual delivery timestamps and still need investigation.

## Why I checked the data

Before analyzing deliveries, reviews, and repeat purchases, I wanted to make sure the data had loaded correctly and the relationships between tables worked as intended. I checked record counts, keys, unmatched records, and missing or unusual values.

The reproducible checks are in [`oracle/04_data_validation.sql`](../oracle/04_data_validation.sql). I ran these checks in Oracle SQL Developer on November 10, 2026. I compared staging and final-table counts using the load rules, checked the constraints, and reviewed missing values by order status. The eight delivered-status records without delivery timestamps are noted below rather than silently removed.

## 1. Source-to-final row-count reconciliation

These counts come from a SQL query comparing the staging tables with the final tables. The expected counts follow the deduplication and row-selection rules in `oracle/03_load.sql` (SQL Developer results, November 10, 2026).

| Final table | Source rows | Expected final rows | Actual final rows | Status |
|---|---:|---:|---:|---|
| CUSTOMERS | 99,441 | 96,096 | 96,096 | MATCH |
| LOCATIONS | 102,536 | 15,078 | 15,078 | MATCH |
| ORDERS | 99,441 | 99,441 | 99,441 | MATCH |
| ORDER_ITEMS | 112,650 | 112,650 | 112,650 | MATCH |
| ORDER_PAYMENTS | 103,886 | 103,886 | 103,886 | MATCH |
| ORDER_REVIEWS | 99,224 | 99,224 | 99,224 | MATCH |
| PRODUCTS | 32,951 | 32,951 | 32,951 | MATCH |
| PRODUCT_CATEGORIES | 32,951 | 73 | 73 | MATCH |
| SELLERS | 3,095 | 3,095 | 3,095 | MATCH |

**Result: 9/9 final-table counts match their transformation-aware expected counts.**

**What the counts mean:**
- **CUSTOMERS:** 99,441 raw customer rows reduce to 96,096 unique `customer_unique_id` records from the customer/order join, selecting the ZIP prefix from the most recent order.
- **LOCATIONS:** 102,536 source customer/seller location observations (99,441 + 3,095) reduce to 15,078 unique ZIP prefixes; city/state values are selected by frequency.
- **PRODUCT_CATEGORIES:** The source count is the 32,951 product records from which 73 distinct non-null Portuguese category names are extracted. It is *not* the row count of the separate translation CSV.
- **Other tables:** The recorded load rules preserve one final row per applicable staging row (or joined source row for ORDERS).

**Limitations:** Row-count agreement confirms cardinality, not that every source record has been mapped correctly or that values were transformed accurately. This table reports counts from the current staging data and final tables, not an independent comparison to the original CSV files. Do not sum source rows across these rows, because several derived tables reuse the same source datasets.

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

**Orphan records: 0 in all three checks.** I used left joins to look for items, payments, and reviews whose orders were missing:

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

**Missing order fields (November 10, 2026):** SQL Developer reported **99,441 total orders**, **0** missing customer IDs, **0** missing purchase timestamps, **2,965** missing actual delivery timestamps, and **0** missing estimated delivery timestamps. Thus **96,476** orders have a populated actual delivery timestamp, and the missing actual-delivery share is **2.98%** (2,965 / 99,441 × 100, rounded). These are observed missing values, not yet classified as data errors.

**Review-score validation (November 10, 2026):** SQL Developer screenshot shows **99,224 total reviews**, **0 missing review scores**, minimum score **1**, and maximum score **5**. A separate SQL query confirmed **0 review scores outside 1–5**. Together with zero missing scores, this confirms all 99,224 review scores satisfy the expected range. Evidence: project owner's SQL Developer screenshot, November 10, 2026.

A missing delivery date does not always mean a bad record: an order may not have reached the customer. I broke the missing dates down by status to see which ones needed attention. The review-score checks passed.

### Missing delivery timestamps by order status (verified)

| Order status | Total orders | Missing actual delivery timestamps |
|---|---:|---:|
| delivered | 96,478 | 8 |
| shipped | 1,107 | 1,107 |
| canceled | 625 | 619 |
| unavailable | 609 | 609 |
| invoiced | 314 | 314 |
| processing | 301 | 301 |
| created | 5 | 5 |
| approved | 2 | 2 |
| **TOTAL** | **99,441** | **2,965** |

**Interpretation:** These counts reconcile exactly with the earlier missing-value query. Of the 2,965 missing delivery timestamps, **2,957** belong to orders whose status is not `delivered`; **8** belong to orders marked `delivered` and warrant investigation as possible status/timestamp inconsistencies. Six `canceled` orders have populated delivery timestamps (625 canceled minus 619 missing); investigate if relevant rather than assuming they are errors.

**How I handle this in analysis:** I compare delivery timing only for records with both actual and estimated delivery timestamps and identify when a query is limited to delivered orders. I do not classify orders with missing dates as on-time or late.

**Evidence:** Project owner's Oracle SQL Developer screenshot, November 10, 2026.

## 5. Limitations

- The historical dataset covers 2016–2018 and one marketplace.
- The normalized customer table keeps one ZIP prefix per unique customer; that may not describe their location at the time of every order.
- Foreign-key checks alone cannot establish that every source CSV row was imported.
- Missing delivery timestamps and non-unique source review IDs need to be considered when interpreting analyses; no missing or out-of-range review scores were found.

## 6. What still needs attention

The planned validation queries have been run and documented. The eight delivered-status orders without an actual delivery timestamp should be reviewed separately. Analysis can proceed as long as queries handle missing timestamps explicitly and the limitations stay documented.
