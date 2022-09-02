-- Load data from S3 to Redshift

-- Copy sales data from S3
COPY staging.sales_raw
FROM 's3://your-bucket/data/sales/'
IAM_ROLE 'arn:aws:iam::123456789012:role/redshift-s3-access-role'
FORMAT AS CSV
DELIMITER ','
IGNOREHEADER 1
DATEFORMAT 'auto'
TIMEFORMAT 'auto'
REGION 'us-east-1'
MAXERROR 100;

-- Load dimension tables
INSERT INTO dwh.dim_customer (customer_id, customer_name, email, city, state, country, effective_date, is_current)
SELECT DISTINCT
    customer_id,
    customer_name,
    email,
    city,
    state,
    country,
    GETDATE() AS effective_date,
    TRUE AS is_current
FROM staging.customers_raw
WHERE customer_id NOT IN (SELECT customer_id FROM dwh.dim_customer WHERE is_current = TRUE);

-- Load fact table
INSERT INTO dwh.fact_sales (order_id, customer_key, product_key, order_date_key, quantity, unit_price, total_amount)
SELECT 
    s.order_id,
    c.customer_key,
    p.product_key,
    TO_NUMBER(TO_CHAR(s.order_date::DATE, 'YYYYMMDD'), '99999999') AS order_date_key,
    s.quantity::INTEGER,
    s.unit_price::DECIMAL(18,2),
    s.total_amount::DECIMAL(18,2)
FROM staging.sales_raw s
INNER JOIN dwh.dim_customer c ON s.customer_id = c.customer_id AND c.is_current = TRUE
INNER JOIN dwh.dim_product p ON s.product_id = p.product_id AND p.is_current = TRUE;

-- Vacuum and analyze
VACUUM dwh.fact_sales;
ANALYZE dwh.fact_sales;
