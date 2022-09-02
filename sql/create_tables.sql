-- AWS Redshift Analytics Platform
-- Table Definitions

-- Staging Tables
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.sales_raw (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    order_date VARCHAR(50),
    quantity VARCHAR(20),
    unit_price VARCHAR(20),
    total_amount VARCHAR(20),
    load_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTSTYLE EVEN
SORTKEY (load_timestamp);

-- Dimension Tables
CREATE SCHEMA IF NOT EXISTS dwh;

CREATE TABLE dwh.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE,
    day_of_week INTEGER,
    day_name VARCHAR(10),
    month INTEGER,
    month_name VARCHAR(10),
    quarter INTEGER,
    year INTEGER,
    is_weekend BOOLEAN
)
DISTSTYLE ALL
SORTKEY (date_key);

CREATE TABLE dwh.dim_customer (
    customer_key BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(200),
    email VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(100),
    effective_date TIMESTAMP,
    end_date TIMESTAMP,
    is_current BOOLEAN
)
DISTSTYLE ALL
SORTKEY (customer_id);

CREATE TABLE dwh.dim_product (
    product_key BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    unit_price DECIMAL(18,2),
    effective_date TIMESTAMP,
    end_date TIMESTAMP,
    is_current BOOLEAN
)
DISTSTYLE ALL
SORTKEY (product_id);

-- Fact Table
CREATE TABLE dwh.fact_sales (
    sales_key BIGINT IDENTITY(1,1),
    order_id VARCHAR(50),
    customer_key BIGINT,
    product_key BIGINT,
    order_date_key INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(18,2),
    total_amount DECIMAL(18,2),
    load_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY (customer_key)
SORTKEY (order_date_key);
