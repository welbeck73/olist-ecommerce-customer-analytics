-- Clean the staging data and insert it into the final tables (Oracle).
-- Run 01_schema.sql and 02_staging_tables.sql first and import the CSV files into the stg_ tables.
-- Run this script with "Run Script" (F5).
-- Note: if your session uses a comma as the decimal separator, run  ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';  first.

-- locations: one city/state per zip prefix (the most common spelling wins).
-- The CSV may drop leading zeros, so zip codes are padded to 5 digits.
INSERT INTO locations (zip_prefix, city, state)
WITH all_loc AS (
    SELECT LPAD(customer_zip_code_prefix,5,'0') AS zip, LOWER(TRIM(customer_city)) AS city, UPPER(TRIM(customer_state)) AS state FROM stg_customers
    UNION ALL
    SELECT LPAD(seller_zip_code_prefix,5,'0'),          LOWER(TRIM(seller_city)),            UPPER(TRIM(seller_state))          FROM stg_sellers
), counted AS (
    SELECT zip, city, state, COUNT(*) AS n FROM all_loc GROUP BY zip, city, state
), ranked AS (
    SELECT zip, city, state, ROW_NUMBER() OVER (PARTITION BY zip ORDER BY n DESC, city) AS rn FROM counted
)
SELECT zip, city, state FROM ranked WHERE rn = 1;

-- customers: one row per person; use the zip from their most recent order.
INSERT INTO customers (customer_unique_id, zip_prefix)
SELECT customer_unique_id, zip
FROM (
    SELECT c.customer_unique_id,
           LPAD(c.customer_zip_code_prefix,5,'0') AS zip,
           ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp DESC) AS rn
    FROM stg_customers c
    JOIN stg_orders o ON o.customer_id = c.customer_id
)
WHERE rn = 1;

INSERT INTO sellers (seller_id, zip_prefix)
SELECT seller_id, LPAD(seller_zip_code_prefix,5,'0') FROM stg_sellers;

-- Every category that appears on a product gets a row, even if the translation file lacks it.
INSERT INTO product_categories (category_name, category_name_en)
SELECT d.cat, t.product_category_name_english
FROM (SELECT DISTINCT product_category_name AS cat FROM stg_products WHERE product_category_name IS NOT NULL) d
LEFT JOIN stg_category_translation t ON t.product_category_name = d.cat;

INSERT INTO products (product_id, category_name, photos_qty, weight_g, length_cm, height_cm, width_cm)
SELECT product_id, product_category_name, TO_NUMBER(product_photos_qty), TO_NUMBER(product_weight_g),
       TO_NUMBER(product_length_cm), TO_NUMBER(product_height_cm), TO_NUMBER(product_width_cm)
FROM stg_products;

INSERT INTO orders (order_id, customer_unique_id, status, purchase_ts, approved_ts,
                    delivered_carrier_ts, delivered_customer_ts, estimated_delivery_ts)
SELECT o.order_id, c.customer_unique_id, o.order_status,
       TO_TIMESTAMP(o.order_purchase_timestamp,       'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(o.order_approved_at,              'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(o.order_delivered_carrier_date,   'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(o.order_delivered_customer_date,  'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(o.order_estimated_delivery_date,  'YYYY-MM-DD HH24:MI:SS')
FROM stg_orders o
JOIN stg_customers c ON c.customer_id = o.customer_id;

INSERT INTO order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_ts, price, freight_value)
SELECT order_id, TO_NUMBER(order_item_id), product_id, seller_id,
       TO_TIMESTAMP(shipping_limit_date, 'YYYY-MM-DD HH24:MI:SS'), TO_NUMBER(price), TO_NUMBER(freight_value)
FROM stg_items;

INSERT INTO order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
SELECT order_id, TO_NUMBER(payment_sequential), payment_type, TO_NUMBER(payment_installments), TO_NUMBER(payment_value)
FROM stg_payments;

INSERT INTO order_reviews (review_id, order_id, review_score, comment_title, comment_message, created_ts, answered_ts)
SELECT review_id, order_id, TO_NUMBER(review_score), review_comment_title, review_comment_message,
       TO_TIMESTAMP(review_creation_date,   'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(review_answer_timestamp,'YYYY-MM-DD HH24:MI:SS')
FROM stg_reviews;

COMMIT;

-- Sanity check: row counts of the final tables (compare orders, items, payments, reviews with the CSV row counts).
SELECT 'locations' AS tbl, COUNT(*) AS row_count FROM locations
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'product_categories', COUNT(*) FROM product_categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;