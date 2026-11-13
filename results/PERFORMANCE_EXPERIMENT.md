# Phase 6 — Oracle SQL query performance experiment

I am comparing how Oracle executes two equivalent versions of a monthly sales query before making any indexing changes. The database already has an index on `ORDERS.PURCHASE_TS` (`IDX_ORDERS_PURCHASE`), so this is **not** a comparison of an unindexed database against an indexed one.

## Question

Does filtering a month using `TRUNC(purchase_ts, 'MM')` lead Oracle to choose a different execution plan than filtering with an inclusive/exclusive timestamp range?

Both versions join `ORDERS` to `ORDER_ITEMS` and measure the number of distinct orders and total item-price sales for November 2017.

## Procedure

1. Run [`oracle/05_performance_baseline.sql`](../oracle/05_performance_baseline.sql) in SQL Developer using the project database connection.
2. Record the names and statuses of existing indexes from `USER_INDEXES`.
3. Save the output of each `DBMS_XPLAN.DISPLAY` call. Compare table access, index access, join strategy, estimated row counts, and optimizer cost.
4. Execute both actual SELECT statements to confirm they return the same order count and item-price sales.
5. Only after reviewing this baseline, decide whether testing a new index is justified. Record experimental changes and their effects separately.

## Results

**Index inventory verified in SQL Developer (November 13, 2026):**

| Index | Reported status | Uniqueness |
|---|---|---|
| `IDX_ORDERS_CUSTOMER` | VALID | NONUNIQUE |
| `IDX_ORDERS_PURCHASE` | VALID | NONUNIQUE |
| `SYS_C0036983` | VALID | UNIQUE |

The screenshot establishes that these indexes exist and have `VALID` status. The `SYS_C0036983` index is likely associated with the primary key; its columns have not been verified in the index-inventory output. **Test A / TRUNC() plan verified from SQL Developer screenshot (November 13, 2026):**

| Plan detail | Oracle EXPLAIN PLAN output |
|---|---|
| Statement ID | `OLIST_Q2_TRUNC_BASE` |
| Plan hash value | `3479646620` |
| Estimated statement cost | 1,029 |
| `ORDERS` access | `TABLE ACCESS FULL`, estimated 994 rows, cost 481 |
| `ORDER_ITEMS` access | `TABLE ACCESS FULL`, estimated 112K rows, cost 546 |
| Join | `HASH JOIN`, estimated 1,101 rows, cost 1,028 |
| Aggregation | `HASH GROUP BY` and `SORT AGGREGATE` |
| Predicate | Filter applies `TRUNC` to the purchase timestamp |

This demonstrates the optimizer's **estimated** choice for the TRUNC-based filter, not its actual elapsed runtime. The index on `ORDERS.PURCHASE_TS` existed but was not chosen for this plan. Oracle may reasonably prefer full table access for this query and dataset.

**Test B / date-range plan verified from SQL Developer screenshot (November 13, 2026):**

| Plan detail | Oracle EXPLAIN PLAN output |
|---|---|
| Statement ID | `OLIST_Q2_RANGE_BASE` |
| Plan hash value | `3479646620` |
| Estimated statement cost | 1,026 |
| `ORDERS` access | `TABLE ACCESS FULL`, estimated 7,622 rows, cost 478 |
| `ORDER_ITEMS` access | `TABLE ACCESS FULL`, estimated 112K rows, cost 546 |
| Join | `HASH JOIN`, estimated 8,440 rows, cost 1,025 |
| Aggregation | `HASH GROUP BY` and `SORT AGGREGATE` |
| Predicate | `PURCHASE_TS >= TIMESTAMP '2017-11-01 00:00:00'` and `PURCHASE_TS < TIMESTAMP '2017-12-01 00:00:00'` |

**Comparison:** Both plans have the same plan hash (`3479646620`) and use full scans of both tables with a hash join. The estimated statement cost is 1,029 for the TRUNC version and 1,026 for the range version, a difference of `(1029 - 1026) / 1029 × 100 ≈ 0.29%`. The estimated filtered `ORDERS` row count changes from 994 to 7,622, despite the calendar-month predicates being semantically equivalent. The screenshot does not establish why these estimates differ.

**Still pending:** Execute the actual SELECTs to confirm equal order counts and item-price sales, then collect repeatable runtime measurements if practical. No actual speedup has been demonstrated.

## Notes and limitations

An `EXPLAIN PLAN` is an **estimated plan**, not a benchmark of elapsed runtime. Optimizer choices depend on table statistics, indexing, data distribution, and database configuration. A lower plan cost does not guarantee that a query actually runs faster. For reliable timing claims, compare multiple executions in similar conditions and consider database caching and cloud workload variation.

The two filter styles have the same date semantics for `purchase_ts` values in November 2017. Both exclude orders with no matching order item because of the inner join.
