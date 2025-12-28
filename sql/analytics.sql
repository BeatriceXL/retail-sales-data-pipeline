-- 1) Total sales by month
SELECT
  d.year,
  d.month,
  SUM(f.total_amount) AS total_sales
FROM curated.fact_sales f
JOIN curated.dim_date d ON f.date_id = d.date_id
GROUP BY 1,2
ORDER BY 1,2;

-- 2) Sales by product category
SELECT
  p.category_name,
  SUM(f.total_amount) AS total_sales
FROM curated.fact_sales f
JOIN curated.dim_product_category p ON f.product_category_id = p.product_category_id
GROUP BY 1
ORDER BY total_sales DESC;

-- 3) Average order value (AOV) by category
SELECT
  p.category_name,
  AVG(f.total_amount) AS avg_order_value
FROM curated.fact_sales f
JOIN curated.dim_product_category p ON f.product_category_id = p.product_category_id
GROUP BY 1
ORDER BY avg_order_value DESC;

-- 4) Sales by age_group
SELECT
  c.age_group,
  SUM(f.total_amount) AS total_sales,
  COUNT(*) AS transactions
FROM curated.fact_sales f
JOIN curated.dim_customer c ON f.customer_id = c.customer_id
GROUP BY 1
ORDER BY total_sales DESC;

-- 5) Daily sales trend
SELECT
  d.date,
  SUM(f.total_amount) AS daily_sales
FROM curated.fact_sales f
JOIN curated.dim_date d ON f.date_id = d.date_id
GROUP BY 1
ORDER BY 1;

-- 6) Rolling 7-day sales (Window Function)
SELECT
  d.date,
  SUM(f.total_amount) AS daily_sales,
  SUM(SUM(f.total_amount)) OVER (
    ORDER BY d.date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS rolling_7d_sales
FROM curated.fact_sales f
JOIN curated.dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;

-- 7) Top 10 customers by spend
SELECT
  f.customer_id,
  SUM(f.total_amount) AS total_spend
FROM curated.fact_sales f
GROUP BY 1
ORDER BY total_spend DESC
LIMIT 10;

-- 8) Data quality check: total_amount should equal quantity * price_per_unit
SELECT
  COUNT(*) AS mismatch_count
FROM curated.fact_sales
WHERE total_amount <> quantity * price_per_unit;
