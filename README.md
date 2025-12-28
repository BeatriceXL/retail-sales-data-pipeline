# Retail Sales Data Pipeline (PostgreSQL + Python + Docker)

## Overview
This project implements an end-to-end data pipeline that ingests raw retail sales data, performs data cleaning and standardization, loads curated datasets into PostgreSQL, and builds an analytics-ready star schema for downstream reporting and SQL analysis.

Dataset: Kaggle Retail Sales Dataset (single CSV).

## Tech Stack
- Python (pandas) for data cleaning (clean layer)
- PostgreSQL for storage and dimensional modeling (curated layer)
- Docker Compose for local reproducible environment
- SQL for schema creation, transformation, and analytics queries

## Architecture (Medallion + Star Schema)

### Layers
- **Raw**: Source-aligned table for traceability and reprocessing
- **Clean**: Standardized dataset (naming, types, basic validation)
- **Curated**: Dimensional model (star schema) for analytics

### Curated Star Schema
- `curated.fact_sales(transaction_id, date_id, customer_id, product_category_id, quantity, price_per_unit, total_amount)`
- `curated.dim_date(date_id, date, year, month, day, day_of_week)`
- `curated.dim_customer(customer_id, gender, age, age_group)`
- `curated.dim_product_category(product_category_id, category_name)`

## Data Quality Checks
- No missing values across all columns (raw profiling)
- No duplicate `transaction_id`
- Business rule validation:
  - `total_amount = quantity * price_per_unit`
  - Verified in curated layer with `mismatch_count = 0`

## Build Results (Row Counts)
- `clean.retail_sales`: 1000
- `curated.dim_date`: 345
- `curated.dim_customer`: 1000
- `curated.dim_product_category`: 3
- `curated.fact_sales`: 1000

## How to Run

### 1) Start PostgreSQL and create schemas/tables
```bash
docker compose up -d
docker exec -i retail_postgres psql -U retail -d retail_db < sql/schema.sql

### 2) Build the clean layer (local)
python scripts/transform.py

### 3) Load clean CSV into PostgreSQL
docker cp data/clean/clean_retail_sales_dataset.csv retail_postgres:/tmp/clean_retail_sales_dataset.csv

docker exec -it retail_postgres psql -U retail -d retail_db \
  -c "\copy clean.retail_sales FROM '/tmp/clean_retail_sales_dataset.csv' WITH (FORMAT csv, HEADER true);"

docker exec -it retail_postgres psql -U retail -d retail_db \
  -c "SELECT COUNT(*) FROM clean.retail_sales;"

### 4) Build curated star schema (dimensions + fact)
docker exec -i retail_postgres psql -U retail -d retail_db < sql/build_curated.sql

### 5)Run analytics queries
docker exec -i retail_postgres psql -U retail -d retail_db < sql/analytics.sql

## Sample Analytics Included
- Monthly sales trend
- Sales by product category
- Average order value (AOV) by category
- Sales by customer age group
- Daily sales trend + rolling 7-day sales (window function)
- Top customers by spend
- Data quality validation query (mismatch_count = 0)