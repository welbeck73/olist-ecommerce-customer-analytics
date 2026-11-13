-- 10 business queries for the Olist database (Oracle SQL Developer)
-- Run one query at a time: place the cursor in it and press "Run Statement" (Ctrl+Enter).
-- For each one: note the question, the SQL, the result, and a one-line finding in your report.

-- Q1. Which product categories earn the most revenue? (delivered orders only)
SELECT COALESCE(pc.category_name_en, p.category_name, 'unknown') AS category,
       ROUND(SUM(oi.price), 2) AS revenue,
       COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_categories pc ON pc.category_name = p.category_name
WHERE o.status = 'delivered'
GROUP BY COALESCE(pc.category_name_en, p.category_name, 'unknown')
ORDER BY revenue DESC
FETCH FIRST 10 ROWS ONLY;

-- Q2. How do orders and revenue change month by month?
SELECT TRUNC(o.purchase_ts, 'MM') AS order_month,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.price), 2)    AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY TRUNC(o.purchase_ts, 'MM')
ORDER BY order_month;

-- Q3. What happens to orders? (status breakdown, window function for the percentage)
SELECT status, COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- Q4. Which states have the highest share of late deliveries?
SELECT l.state,
       COUNT(*) AS delivered_orders,
       ROUND(100.0 * SUM(CASE WHEN o.delivered_customer_ts > o.estimated_delivery_ts THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM orders o
JOIN customers c ON c.customer_unique_id = o.customer_unique_id
JOIN locations l ON l.zip_prefix = c.zip_prefix
WHERE o.status = 'delivered'
  AND o.delivered_customer_ts IS NOT NULL
  AND o.estimated_delivery_ts IS NOT NULL
GROUP BY l.state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;

-- Q5. Are late deliveries associated with lower customer review scores?
-- One observation per delivered order: average multiple reviews within an order first.
-- Excludes orders missing actual or estimated delivery timestamps.
WITH reviews_per_order AS (
    SELECT order_id, AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
),
delivery_analysis AS (
    SELECT o.order_id,
           CASE WHEN o.delivered_customer_ts > o.estimated_delivery_ts
                THEN 'Late' ELSE 'On Time' END AS delivery_status,
           r.avg_review_score
    FROM orders o
    JOIN reviews_per_order r ON r.order_id = o.order_id
    WHERE o.status = 'delivered'
      AND o.delivered_customer_ts IS NOT NULL
      AND o.estimated_delivery_ts IS NOT NULL
)
SELECT delivery_status,
       COUNT(*) AS total_orders,
       ROUND(AVG(avg_review_score), 2) AS avg_review_score
FROM delivery_analysis
GROUP BY delivery_status
ORDER BY delivery_status;

-- Q6. What fraction of unique customers placed more than one order?
-- Observed repeat-purchase rate within the historical dataset, not lifetime retention.
WITH customer_orders AS (
    SELECT customer_unique_id,
           COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_unique_id
)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(
           100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
           / NULLIF(COUNT(*), 0),
           2
       ) AS repeat_customer_pct
FROM customer_orders;

-- Q7. Which 10 sellers have the highest delivered-order item-price sales?
-- Review scores are calculated once per order before averaging by seller.
-- An order involving several sellers can contribute its review to each seller.
WITH seller_sales AS (
    SELECT oi.seller_id,
           ROUND(SUM(oi.price), 2) AS revenue,
           COUNT(DISTINCT oi.order_id) AS orders
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY oi.seller_id
),
top_sellers AS (
    SELECT seller_id, revenue, orders
    FROM seller_sales
    ORDER BY revenue DESC
    FETCH FIRST 10 ROWS ONLY
),
reviews_per_order AS (
    SELECT order_id,
           AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
),
seller_orders AS (
    SELECT DISTINCT oi.seller_id, oi.order_id
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN top_sellers ts ON ts.seller_id = oi.seller_id
    WHERE o.status = 'delivered'
)
SELECT ts.seller_id,
       ts.revenue,
       ts.orders,
       COUNT(r.avg_review_score) AS reviewed_orders,
       ROUND(AVG(r.avg_review_score), 2) AS avg_review
FROM top_sellers ts
LEFT JOIN seller_orders so ON so.seller_id = ts.seller_id
LEFT JOIN reviews_per_order r ON r.order_id = so.order_id
GROUP BY ts.seller_id, ts.revenue, ts.orders
ORDER BY ts.revenue DESC;

-- Q8. How do customers pay? (window function for the share of total)
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(payment_value), 2) AS total_paid,
       ROUND(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 2) AS pct_of_total
FROM order_payments
GROUP BY payment_type
ORDER BY total_paid DESC;

-- Q9. How many days does delivery take, by state? (slowest first)
-- Casting a TIMESTAMP to DATE lets Oracle subtract the two values to get days.
SELECT l.state,
       COUNT(*) AS orders,
       ROUND(AVG(CAST(o.delivered_customer_ts AS DATE) - CAST(o.purchase_ts AS DATE)), 1) AS avg_days
FROM orders o
JOIN customers c ON c.customer_unique_id = o.customer_unique_id
JOIN locations l ON l.zip_prefix = c.zip_prefix
WHERE o.status = 'delivered'
  AND o.delivered_customer_ts IS NOT NULL
  AND o.purchase_ts IS NOT NULL
GROUP BY l.state
HAVING COUNT(*) >= 100
ORDER BY avg_days DESC;

-- Q10. Which product categories have the lowest average order-review scores?
-- One observation per distinct order/category combination.
-- Multiple reviews on the same order are averaged before category analysis.
-- The review concerns the whole order, not necessarily a specific product.
WITH order_reviews_one_row AS (
    SELECT order_id,
           AVG(review_score) AS order_avg_review
    FROM order_reviews
    GROUP BY order_id
),
order_categories AS (
    SELECT DISTINCT
           oi.order_id,
           COALESCE(pc.category_name_en, p.category_name, 'unknown') AS category
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN product_categories pc ON pc.category_name = p.category_name
)
SELECT oc.category,
       COUNT(*) AS reviewed_orders,
       ROUND(AVG(r.order_avg_review), 2) AS avg_review
FROM order_categories oc
JOIN order_reviews_one_row r ON r.order_id = oc.order_id
GROUP BY oc.category
HAVING COUNT(*) >= 100
ORDER BY avg_review ASC, reviewed_orders DESC, oc.category
FETCH FIRST 10 ROWS ONLY;