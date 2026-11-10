"""Prepare Olist CSV files for Oracle SQL Developer import."""
import csv
from pathlib import Path
import pandas as pd

SRC, DST = Path("data"), Path("data/oracle")
FILES = [
    "olist_customers_dataset.csv",
    "olist_sellers_dataset.csv",
    "olist_products_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "product_category_name_translation.csv",
]

DST.mkdir(parents=True, exist_ok=True)
for name in FILES:
    path = SRC / name
    if not path.exists():
        print(f"MISSING: {path}")
        continue
    df = pd.read_csv(path, dtype=str, keep_default_na=False, encoding="utf-8-sig")
    for col in df.columns:
        df[col] = df[col].str.replace(r"[\r\n]+", " ", regex=True)
    df.to_csv(DST / name, index=False, quoting=csv.QUOTE_MINIMAL, encoding="utf-8")
    print(f"{name}: {len(df):,} rows -> {DST / name}")
