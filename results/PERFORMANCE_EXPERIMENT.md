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

**Not yet executed.** Query plans, runtime measurements, and performance improvements have not been established. This document is a repeatable experiment protocol, not evidence of faster execution.

## Notes and limitations

An `EXPLAIN PLAN` is an **estimated plan**, not a benchmark of elapsed runtime. Optimizer choices depend on table statistics, indexing, data distribution, and database configuration. A lower plan cost does not guarantee that a query actually runs faster. For reliable timing claims, compare multiple executions in similar conditions and consider database caching and cloud workload variation.

The two filter styles have the same date semantics for `purchase_ts` values in November 2017. Both exclude orders with no matching order item because of the inner join.
