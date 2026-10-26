-- ==============================================================================
-- 03_curated / 01_dimensions.sql
-- Dimensional model: Conformed Dimension tables with surrogate keys and grain
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA CURATED;

-- 1. DIM_DATE
-- Granularity: One record per calendar day (covering 2020 to 2030)
CREATE OR REPLACE TABLE CURATED.DIM_DATE AS
WITH date_spine AS (
    SELECT DATEADD(day, SEQ4(), '2020-01-01'::DATE) AS calendar_date
    FROM TABLE(GENERATOR(ROWCOUNT => 365 * 11 + 3)) -- ~11 years
)
SELECT
    TO_NUMBER(TO_CHAR(calendar_date, 'YYYYMMDD'))              AS date_key,
    calendar_date,
    EXTRACT(year FROM calendar_date)                           AS year_num,
    EXTRACT(quarter FROM calendar_date)                        AS quarter_num,
    CONCAT('Q', EXTRACT(quarter FROM calendar_date))           AS quarter_name,
    EXTRACT(month FROM calendar_date)                          AS month_num,
    MONTHNAME(calendar_date)                                   AS month_name,
    EXTRACT(day FROM calendar_date)                            AS day_of_month,
    EXTRACT(dayofweek FROM calendar_date)                      AS day_of_week,
    DAYNAME(calendar_date)                                     AS day_name,
    CASE WHEN EXTRACT(dayofweek FROM calendar_date) IN (0, 6) 
         THEN TRUE ELSE FALSE END                              AS is_weekend
FROM date_spine;

-- 2. DIM_CUSTOMER
-- Granularity: One record per unique customer
CREATE OR REPLACE TABLE CURATED.DIM_CUSTOMER AS
SELECT
    MD5(customer_id)                                           AS customer_key,
    customer_id                                                AS customer_id_nk,
    first_name,
    last_name,
    full_name,
    email,
    phone,
    address,
    city,
    state,
    zip_code,
    country,
    signup_date,
    TO_NUMBER(TO_CHAR(signup_date, 'YYYYMMDD'))                AS signup_date_key,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_CUSTOMERS;

-- 3. DIM_PRODUCT
-- Granularity: One record per unique product
CREATE OR REPLACE TABLE CURATED.DIM_PRODUCT AS
SELECT
    MD5(product_id)                                            AS product_key,
    product_id                                                 AS product_id_nk,
    product_name,
    category,
    subcategory,
    unit_cost,
    unit_price,
    ROUND((unit_price - unit_cost), 2)                         AS unit_margin,
    CASE 
        WHEN unit_price > 0 
        THEN ROUND(((unit_price - unit_cost) / unit_price) * 100, 2)
        ELSE 0.00 
    END                                                        AS gross_margin_pct,
    sku,
    is_active,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_PRODUCTS;
