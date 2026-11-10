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
WHERE o.status = 'delivered' AND o.delivered_customer_ts IS NOT NULL
GROUP BY l.state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;

-- Q5. Do late deliveries get worse reviews? (the main story of the project)
SELECT delivery,
       COUNT(*) AS reviews,
       ROUND(AVG(review_score), 2) AS avg_review
FROM (
    SELECT CASE WHEN o.delivered_customer_ts > o.estimated_delivery_ts THEN 'late' ELSE 'on time' END AS delivery,
           r.review_score
    FROM orders o
    JOIN order_reviews r ON r.order_id = o.order_id
    WHERE o.status = 'delivered' AND o.delivered_customer_ts IS NOT NULL
)
GROUP BY delivery;

-- Q6. How many customers come back? (repeat purchase rate)
SELECT COUNT(*) AS customers,
       SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_pct
FROM (SELECT customer_unique_id, COUNT(*) AS n FROM orders GROUP BY customer_unique_id) t;

-- Q7. Who are the top 10 sellers by revenue, and how are they reviewed?
-- Revenue is summed in a subquery first so multiple reviews per order do not inflate it.
SELECT s.seller_id,
       s.revenue,
       s.orders,
       ROUND(AVG(r.review_score), 2) AS avg_review
FROM (
    SELECT oi.seller_id,
           ROUND(SUM(oi.price), 2) AS revenue,
           COUNT(DISTINCT oi.order_id) AS orders
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY oi.seller_id
    ORDER BY revenue DESC
    FETCH FIRST 10 ROWS ONLY
) s
LEFT JOIN order_items oi2 ON oi2.seller_id = s.seller_id
LEFT JOIN order_reviews r ON r.order_id = oi2.order_id
GROUP BY s.seller_id, s.revenue, s.orders
ORDER BY s.revenue DESC;

-- Q8. How do customers pay? (window function for the share of total)
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(payment_value), 2) AS total_paid,
       ROUND(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 1) AS pct_of_total
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
WHERE o.delivered_customer_ts IS NOT NULL
GROUP BY l.state
HAVING COUNT(*) >= 100
ORDER BY avg_days DESC;

-- Q10. Which categories are reviewed worst? (at least 100 reviewed items)
-- Note: one row per order item, so an order with several items counts once per item.
SELECT COALESCE(pc.category_name_en, p.category_name, 'unknown') AS category,
       COUNT(*) AS reviewed_items,
       ROUND(AVG(r.review_score), 2) AS avg_review
FROM order_items oi
JOIN order_reviews r ON r.order_id = oi.order_id
JOIN products p      ON p.product_id = oi.product_id
LEFT JOIN product_categories pc ON pc.category_name = p.category_name
GROUP BY COALESCE(pc.category_name_en, p.category_name, 'unknown')
HAVING COUNT(*) >= 100
ORDER BY avg_review ASC
FETCH FIRST 10 ROWS ONLY;