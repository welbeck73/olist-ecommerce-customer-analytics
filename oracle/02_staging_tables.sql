-- Staging tables for the raw CSV files (Oracle SQL Developer).
-- Every column is VARCHAR2 so the import never fails on bad values; real data types are applied in 03_load.sql.
-- Run this script first (F5), then import each CSV into its staging table (see README, "Oracle: loading the CSV files").

BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name LIKE 'STG\_%' ESCAPE '\') LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' PURGE';
    END LOOP;
END;
/

CREATE TABLE stg_customers (customer_id VARCHAR2(100), customer_unique_id VARCHAR2(100), customer_zip_code_prefix VARCHAR2(20),
                            customer_city VARCHAR2(200), customer_state VARCHAR2(10));
CREATE TABLE stg_sellers   (seller_id VARCHAR2(100), seller_zip_code_prefix VARCHAR2(20), seller_city VARCHAR2(200), seller_state VARCHAR2(10));
CREATE TABLE stg_products  (product_id VARCHAR2(100), product_category_name VARCHAR2(200), product_name_lenght VARCHAR2(50),
                            product_description_lenght VARCHAR2(50), product_photos_qty VARCHAR2(50), product_weight_g VARCHAR2(50),
                            product_length_cm VARCHAR2(50), product_height_cm VARCHAR2(50), product_width_cm VARCHAR2(50));
CREATE TABLE stg_orders    (order_id VARCHAR2(100), customer_id VARCHAR2(100), order_status VARCHAR2(50), order_purchase_timestamp VARCHAR2(50),
                            order_approved_at VARCHAR2(50), order_delivered_carrier_date VARCHAR2(50),
                            order_delivered_customer_date VARCHAR2(50), order_estimated_delivery_date VARCHAR2(50));
CREATE TABLE stg_items     (order_id VARCHAR2(100), order_item_id VARCHAR2(20), product_id VARCHAR2(100), seller_id VARCHAR2(100),
                            shipping_limit_date VARCHAR2(50), price VARCHAR2(50), freight_value VARCHAR2(50));
CREATE TABLE stg_payments  (order_id VARCHAR2(100), payment_sequential VARCHAR2(20), payment_type VARCHAR2(50),
                            payment_installments VARCHAR2(20), payment_value VARCHAR2(50));
CREATE TABLE stg_reviews   (review_id VARCHAR2(100), order_id VARCHAR2(100), review_score VARCHAR2(10), review_comment_title VARCHAR2(500),
                            review_comment_message VARCHAR2(4000), review_creation_date VARCHAR2(50), review_answer_timestamp VARCHAR2(50));
CREATE TABLE stg_category_translation (product_category_name VARCHAR2(200), product_category_name_english VARCHAR2(200));