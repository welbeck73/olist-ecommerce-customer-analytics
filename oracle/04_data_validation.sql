-- Olist E-Commerce Customer Analytics
-- Phase 4: Data quality and relational integrity validation
-- Run as the OLIST project schema after the final load.
-- Read-only checks: no data is modified.

-- 1. Final-table row counts
SELECT 'CUSTOMERS' table_name, COUNT(*) row_count FROM customers
UNION ALL SELECT 'LOCATIONS', COUNT(*) FROM locations
UNION ALL SELECT 'SELLERS', COUNT(*) FROM sellers
UNION ALL SELECT 'PRODUCT_CATEGORIES', COUNT(*) FROM product_categories
UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM products
UNION ALL SELECT 'ORDERS', COUNT(*) FROM orders
UNION ALL SELECT 'ORDER_ITEMS', COUNT(*) FROM order_items
UNION ALL SELECT 'ORDER_PAYMENTS', COUNT(*) FROM order_payments
UNION ALL SELECT 'ORDER_REVIEWS', COUNT(*) FROM order_reviews
ORDER BY table_name;

-- 2. Primary-key definitions and status
SELECT c.table_name, c.constraint_name, c.status, c.validated,
       LISTAGG(cc.column_name, ', ') WITHIN GROUP (ORDER BY cc.position) key_columns
FROM user_constraints c
JOIN user_cons_columns cc ON cc.constraint_name = c.constraint_name
WHERE c.constraint_type = 'P'
  AND c.table_name IN ('CUSTOMERS','LOCATIONS','SELLERS','PRODUCT_CATEGORIES',
                       'PRODUCTS','ORDERS','ORDER_ITEMS','ORDER_PAYMENTS','ORDER_REVIEWS')
GROUP BY c.table_name, c.constraint_name, c.status, c.validated
ORDER BY c.table_name;

-- 3. Foreign-key definitions and status
SELECT c.table_name child_table, c.constraint_name, p.table_name parent_table,
       c.status, c.validated
FROM user_constraints c
JOIN user_constraints p ON p.constraint_name = c.r_constraint_name
WHERE c.constraint_type = 'R'
ORDER BY c.table_name, c.constraint_name;

-- 4. Orphan order items (expected: zero)
SELECT COUNT(*) orphan_order_items
FROM order_items i LEFT JOIN orders o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;

-- 5. Orphan order payments (expected: zero)
SELECT COUNT(*) orphan_order_payments
FROM order_payments p LEFT JOIN orders o ON o.order_id = p.order_id
WHERE o.order_id IS NULL;

-- 6. Orphan order reviews (expected: zero)
SELECT COUNT(*) orphan_order_reviews
FROM order_reviews r LEFT JOIN orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

-- 7. Duplicate order IDs (expected: zero)
SELECT COUNT(*) duplicate_order_id_groups
FROM (SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1);

-- 8. Missing key order fields (some delivery timestamps may be legitimately NULL)
SELECT COUNT(*) total_orders,
       SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) missing_customer_ids,
       SUM(CASE WHEN purchase_ts IS NULL THEN 1 ELSE 0 END) missing_purchase_timestamps,
       SUM(CASE WHEN delivered_customer_ts IS NULL THEN 1 ELSE 0 END) missing_delivery_timestamps,
       SUM(CASE WHEN estimated_delivery_ts IS NULL THEN 1 ELSE 0 END) missing_estimated_timestamps
FROM orders;

-- 9. Review score quality
SELECT COUNT(*) total_reviews,
       SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) missing_review_scores,
       SUM(CASE WHEN review_score NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) out_of_range_review_scores,
       MIN(review_score) minimum_review_score,
       MAX(review_score) maximum_review_score
FROM order_reviews;

-- 10. Order status distribution: helps explain missing delivery timestamps
SELECT status, COUNT(*) order_count,
       SUM(CASE WHEN delivered_customer_ts IS NULL THEN 1 ELSE 0 END) missing_delivery_timestamps
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Review all outputs and compare row counts with the staging/source datasets.
-- A zero orphan count does not prove that every source record was imported.
