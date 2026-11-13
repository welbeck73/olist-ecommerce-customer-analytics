-- Phase 6: Query performance baseline (read-only)
-- Database: Oracle Autonomous Database via Oracle SQL Developer
-- Purpose: compare access paths and execution plans before adding any new index.
--
-- IMPORTANT
-- 1. Run one statement at a time (Ctrl+Enter or Run Statement).
-- 2. Start with A, save the displayed plan, then do B and C.
-- 3. This file does not create, drop, or change tables or indexes.
-- 4. EXPLAIN PLAN shows an estimated plan, not measured elapsed time.
-- 5. Indexes already present in 01_schema.sql include IDX_ORDERS_PURCHASE.
--
-- A. Confirm existing indexes on ORDERS and their status
SELECT index_name, table_name, status, uniqueness
FROM user_indexes
WHERE table_name = 'ORDERS'
ORDER BY index_name;

-- B1. Explain a month filter that applies TRUNC to PURCHASE_TS.
-- The function may make using a normal PURCHASE_TS range index less attractive.
EXPLAIN PLAN SET STATEMENT_ID = 'OLIST_Q2_TRUNC_BASE' FOR
SELECT COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS item_price_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE TRUNC(o.purchase_ts, 'MM') = DATE '2017-11-01';

-- B2. Read the estimated execution plan for the TRUNC version.
SELECT *
FROM TABLE(
    DBMS_XPLAN.DISPLAY(
        'PLAN_TABLE',
        'OLIST_Q2_TRUNC_BASE',
        'BASIC +PREDICATE +COST +ROWS'
    )
);

-- C1. Explain a date-range version with the SAME calendar-month semantics.
-- No index hint: allow the optimizer to choose its own access path.
EXPLAIN PLAN SET STATEMENT_ID = 'OLIST_Q2_RANGE_BASE' FOR
SELECT COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS item_price_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.purchase_ts >= TIMESTAMP '2017-11-01 00:00:00'
  AND o.purchase_ts <  TIMESTAMP '2017-12-01 00:00:00';

-- C2. Read the estimated plan for the range version.
SELECT *
FROM TABLE(
    DBMS_XPLAN.DISPLAY(
        'PLAN_TABLE',
        'OLIST_Q2_RANGE_BASE',
        'BASIC +PREDICATE +COST +ROWS'
    )
);

-- D. Optional: run both SELECTs in B1/C1 without the EXPLAIN PLAN prefix,
-- checking that the order count and item-price sales are identical.
-- These two equivalent November filters should return the same results.
--
-- NEXT (not in this baseline file): measure repeated executions and
-- carefully design a separate index experiment only after reviewing plans.
