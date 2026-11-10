# Entity Relationship Diagram — Oracle 3NF Model

This diagram documents the relationships declared in `oracle/01_schema.sql`. GitHub renders the Mermaid diagram below.

```mermaid
erDiagram
    LOCATIONS ||--o{ CUSTOMERS : "zip_prefix"
    LOCATIONS ||--o{ SELLERS : "zip_prefix"
    CUSTOMERS ||--o{ ORDERS : "customer_unique_id"
    ORDERS ||--o{ ORDER_ITEMS : "order_id"
    PRODUCTS ||--o{ ORDER_ITEMS : "product_id"
    SELLERS ||--o{ ORDER_ITEMS : "seller_id"
    ORDERS ||--o{ ORDER_PAYMENTS : "order_id"
    ORDERS ||--o{ ORDER_REVIEWS : "order_id"
    PRODUCT_CATEGORIES |o--o{ PRODUCTS : "category_name"
    LOCATIONS {
      CHAR zip_prefix PK
      VARCHAR2 city
      CHAR state
    }
    CUSTOMERS {
      VARCHAR2 customer_unique_id PK
      CHAR zip_prefix FK
    }
    SELLERS {
      VARCHAR2 seller_id PK
      CHAR zip_prefix FK
    }
    PRODUCT_CATEGORIES {
      VARCHAR2 category_name PK
      VARCHAR2 category_name_en
    }
    PRODUCTS {
      VARCHAR2 product_id PK
      VARCHAR2 category_name FK
    }
    ORDERS {
      VARCHAR2 order_id PK
      VARCHAR2 customer_unique_id FK
      VARCHAR2 status
      TIMESTAMP purchase_ts
      TIMESTAMP delivered_customer_ts
      TIMESTAMP estimated_delivery_ts
    }
    ORDER_ITEMS {
      VARCHAR2 order_id PK,FK
      NUMBER order_item_id PK
      VARCHAR2 product_id FK
      VARCHAR2 seller_id FK
      NUMBER price
    }
    ORDER_PAYMENTS {
      VARCHAR2 order_id PK,FK
      NUMBER payment_sequential PK
      NUMBER payment_value
    }
    ORDER_REVIEWS {
      NUMBER review_key PK
      VARCHAR2 review_id
      VARCHAR2 order_id FK
      NUMBER review_score
    }
```

**Modeling caveat:** The `customers` table keeps one ZIP prefix per unique customer (chosen from their latest order). Therefore, state-level delivery analysis uses that retained location rather than the historical address on each order. State-level findings should be labeled accordingly. The source dataset has a separate per-order `customer_id`; preserving that mapping in a future version would improve historical geographic accuracy.

**Execution status:** Diagram is derived from SQL definitions; Oracle execution and row-count validation remain pending.
