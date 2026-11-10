-- Olist E-Commerce Database: final tables (3NF), Oracle SQL Developer
-- Open this file in SQL Developer and press "Run Script" (F5), not "Run Statement".
-- Requires Oracle 12c or newer (identity columns, FETCH FIRST).

BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN ('ORDER_REVIEWS','ORDER_PAYMENTS','ORDER_ITEMS','ORDERS',
                                   'PRODUCTS','PRODUCT_CATEGORIES','SELLERS','CUSTOMERS','LOCATIONS')) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

-- Zip-code prefix determines city and state, so they live here once (removes a transitive dependency).
CREATE TABLE locations (
    zip_prefix  CHAR(5)       PRIMARY KEY,
    city        VARCHAR2(100) NOT NULL,
    state       CHAR(2)       NOT NULL
);

-- One row per real person (customer_unique_id), not per order.
CREATE TABLE customers (
    customer_unique_id  VARCHAR2(32) PRIMARY KEY,
    zip_prefix          CHAR(5) NOT NULL REFERENCES locations(zip_prefix)
);

CREATE TABLE sellers (
    seller_id   VARCHAR2(32) PRIMARY KEY,
    zip_prefix  CHAR(5) NOT NULL REFERENCES locations(zip_prefix)
);

-- Category names are Portuguese in the source; the English name is stored once.
CREATE TABLE product_categories (
    category_name     VARCHAR2(100) PRIMARY KEY,
    category_name_en  VARCHAR2(100)
);

CREATE TABLE products (
    product_id     VARCHAR2(32) PRIMARY KEY,
    category_name  VARCHAR2(100) REFERENCES product_categories(category_name),  -- NULL for some products
    photos_qty     NUMBER(3)    CHECK (photos_qty >= 0),
    weight_g       NUMBER(10,2) CHECK (weight_g >= 0),
    length_cm      NUMBER(8,2)  CHECK (length_cm >= 0),
    height_cm      NUMBER(8,2)  CHECK (height_cm >= 0),
    width_cm       NUMBER(8,2)  CHECK (width_cm >= 0)
);

CREATE TABLE orders (
    order_id              VARCHAR2(32) PRIMARY KEY,
    customer_unique_id    VARCHAR2(32) NOT NULL REFERENCES customers(customer_unique_id),
    status                VARCHAR2(20) NOT NULL,
    purchase_ts           TIMESTAMP NOT NULL,
    approved_ts           TIMESTAMP,
    delivered_carrier_ts  TIMESTAMP,
    delivered_customer_ts TIMESTAMP,
    estimated_delivery_ts TIMESTAMP
);

-- Composite key: an order can contain several items.
CREATE TABLE order_items (
    order_id          VARCHAR2(32) NOT NULL REFERENCES orders(order_id),
    order_item_id     NUMBER(4)    NOT NULL,
    product_id        VARCHAR2(32) NOT NULL REFERENCES products(product_id),
    seller_id         VARCHAR2(32) NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_ts TIMESTAMP,
    price             NUMBER(10,2) NOT NULL CHECK (price >= 0),
    freight_value     NUMBER(10,2) NOT NULL CHECK (freight_value >= 0),
    PRIMARY KEY (order_id, order_item_id)
);

-- An order can be paid with several methods (payment_sequential).
CREATE TABLE order_payments (
    order_id             VARCHAR2(32) NOT NULL REFERENCES orders(order_id),
    payment_sequential   NUMBER(4)    NOT NULL,
    payment_type         VARCHAR2(20) NOT NULL,
    payment_installments NUMBER(4),
    payment_value        NUMBER(10,2) NOT NULL CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential)
);

-- review_id is NOT unique in the source data, so a surrogate key is used.
CREATE TABLE order_reviews (
    review_key        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_id         VARCHAR2(32) NOT NULL,
    order_id          VARCHAR2(32) NOT NULL REFERENCES orders(order_id),
    review_score      NUMBER(1)    NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    comment_title     VARCHAR2(255),
    comment_message   VARCHAR2(4000),
    created_ts        TIMESTAMP,
    answered_ts       TIMESTAMP
);

-- Indexes on foreign keys used in joins (revisit during the indexing experiment)
CREATE INDEX idx_orders_customer   ON orders(customer_unique_id);
CREATE INDEX idx_orders_purchase   ON orders(purchase_ts);
CREATE INDEX idx_items_product     ON order_items(product_id);
CREATE INDEX idx_items_seller      ON order_items(seller_id);
CREATE INDEX idx_reviews_order     ON order_reviews(order_id);
CREATE INDEX idx_products_category ON products(category_name);