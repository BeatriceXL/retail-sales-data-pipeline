-- RAW
CREATE SCHEMA IF NOT EXISTS raw;
CREATE TABLE IF NOT EXISTS raw.retail_sales (
  transaction_id      INTEGER PRIMARY KEY,
  date                DATE NOT NULL,
  customer_id         TEXT NOT NULL,
  gender              TEXT NOT NULL,
  age                 INTEGER NOT NULL,
  product_category    TEXT NOT NULL,
  quantity            INTEGER NOT NULL,
  price_per_unit      NUMERIC(12,2) NOT NULL,
  total_amount        NUMERIC(12,2) NOT NULL
);

-- CLEAN
CREATE SCHEMA IF NOT EXISTS clean;
CREATE TABLE IF NOT EXISTS clean.retail_sales (
  transaction_id      INTEGER PRIMARY KEY,
  date                DATE NOT NULL,
  customer_id         TEXT NOT NULL,
  gender              TEXT NOT NULL,
  age                 INTEGER NOT NULL,
  product_category    TEXT NOT NULL,
  quantity            INTEGER NOT NULL,
  price_per_unit      NUMERIC(12,2) NOT NULL,
  total_amount        NUMERIC(12,2) NOT NULL
);

-- CURATED (STAR SCHEMA)
CREATE SCHEMA IF NOT EXISTS curated;

CREATE TABLE IF NOT EXISTS curated.dim_date (
  date_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  date        DATE UNIQUE NOT NULL,
  year        INTEGER NOT NULL,
  month       INTEGER NOT NULL,
  day         INTEGER NOT NULL,
  day_of_week INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS curated.dim_customer (
  customer_id TEXT PRIMARY KEY,
  gender      TEXT NOT NULL,
  age         INTEGER NOT NULL,
  age_group   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS curated.dim_product_category (
  product_category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_name       TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS curated.fact_sales (
  transaction_id       INTEGER PRIMARY KEY,
  date_id              INTEGER NOT NULL REFERENCES curated.dim_date(date_id),
  customer_id          TEXT NOT NULL REFERENCES curated.dim_customer(customer_id),
  product_category_id  INTEGER NOT NULL REFERENCES curated.dim_product_category(product_category_id),
  quantity             INTEGER NOT NULL,
  price_per_unit       NUMERIC(12,2) NOT NULL,
  total_amount         NUMERIC(12,2) NOT NULL
);
