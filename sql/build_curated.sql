BEGIN;

-- 0) Clear curated tables for reruns
TRUNCATE TABLE
  curated.fact_sales,
  curated.dim_date,
  curated.dim_product_category,
  curated.dim_customer
RESTART IDENTITY CASCADE;

-- 1) dim_date
INSERT INTO curated.dim_date (date, year, month, day, day_of_week)
SELECT
  d::date AS date,
  EXTRACT(YEAR FROM d)::int AS year,
  EXTRACT(MONTH FROM d)::int AS month,
  EXTRACT(DAY FROM d)::int AS day,
  EXTRACT(ISODOW FROM d)::int AS day_of_week
FROM (
  SELECT DISTINCT date AS d
  FROM clean.retail_sales
) t
ORDER BY d;

-- 2) dim_product_category
INSERT INTO curated.dim_product_category (category_name)
SELECT DISTINCT product_category
FROM clean.retail_sales
ORDER BY product_category;

-- 3) dim_customer (with age_group bucketing)
INSERT INTO curated.dim_customer (customer_id, gender, age, age_group)
SELECT DISTINCT
  customer_id,
  gender,
  age,
  CASE
    WHEN age < 18 THEN 'Under 18'
    WHEN age BETWEEN 18 AND 24 THEN '18-24'
    WHEN age BETWEEN 25 AND 34 THEN '25-34'
    WHEN age BETWEEN 35 AND 44 THEN '35-44'
    WHEN age BETWEEN 45 AND 54 THEN '45-54'
    WHEN age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
  END AS age_group
FROM clean.retail_sales;

-- 4) fact_sales with FK mapping
INSERT INTO curated.fact_sales (
  transaction_id, date_id, customer_id, product_category_id,
  quantity, price_per_unit, total_amount
)
SELECT
  s.transaction_id,
  d.date_id,
  s.customer_id,
  p.product_category_id,
  s.quantity,
  s.price_per_unit,
  s.total_amount
FROM clean.retail_sales s
JOIN curated.dim_date d
  ON d.date = s.date
JOIN curated.dim_product_category p
  ON p.category_name = s.product_category;

COMMIT;