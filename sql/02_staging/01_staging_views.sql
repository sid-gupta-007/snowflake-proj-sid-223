-- ==============================================================================
-- 02_staging / 01_staging_views.sql
-- Cleaned and standardized staging models with safe type conversions
-- Uses TRY_TO_DATE with 'DD-MM-YYYY' format and safe numerical casting
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA STAGING;

-- 1. STG_CUSTOMERS
CREATE OR REPLACE VIEW STAGING.STG_CUSTOMERS AS
SELECT
    TRIM(customer_id)                                           AS customer_id,
    INITCAP(TRIM(first_name))                                   AS first_name,
    INITCAP(TRIM(last_name))                                    AS last_name,
    CONCAT(INITCAP(TRIM(first_name)), ' ', INITCAP(TRIM(last_name))) AS full_name,
    LOWER(TRIM(email))                                          AS email,
    TRIM(phone)                                                 AS phone,
    TRIM(address)                                               AS address,
    INITCAP(TRIM(city))                                         AS city,
    UPPER(TRIM(state))                                          AS state,
    TRIM(zip_code)                                              AS zip_code,
    UPPER(TRIM(country))                                        AS country,
    TRY_TO_DATE(TRIM(signup_date), 'DD-MM-YYYY')                AS signup_date,
    _loaded_at,
    _source_file
FROM RAW.RAW_CUSTOMERS
WHERE customer_id IS NOT NULL;

-- 2. STG_PRODUCTS
CREATE OR REPLACE VIEW STAGING.STG_PRODUCTS AS
SELECT
    TRIM(product_id)                                            AS product_id,
    TRIM(product_name)                                          AS product_name,
    INITCAP(TRIM(category))                                     AS category,
    INITCAP(TRIM(subcategory))                                  AS subcategory,
    TRY_TO_DECIMAL(TRIM(unit_cost), 10, 2)                      AS unit_cost,
    TRY_TO_DECIMAL(TRIM(unit_price), 10, 2)                     AS unit_price,
    UPPER(TRIM(sku))                                            AS sku,
    COALESCE(UPPER(TRIM(is_active)) IN ('TRUE', '1', 'YES', 'Y'), TRUE) AS is_active,
    _loaded_at,
    _source_file
FROM RAW.RAW_PRODUCTS
WHERE product_id IS NOT NULL;

-- 3. STG_ORDERS
CREATE OR REPLACE VIEW STAGING.STG_ORDERS AS
SELECT
    TRIM(order_id)                                              AS order_id,
    TRIM(customer_id)                                           AS customer_id,
    TRY_TO_DATE(TRIM(order_date), 'DD-MM-YYYY')                 AS order_date,
    UPPER(TRIM(order_status))                                   AS order_status,
    INITCAP(TRIM(channel))                                      AS channel,
    INITCAP(TRIM(payment_method))                               AS payment_method,
    COALESCE(TRY_TO_DECIMAL(TRIM(shipping_fee), 10, 2), 0.00)   AS shipping_fee,
    COALESCE(TRY_TO_DECIMAL(TRIM(tax_amount), 10, 2), 0.00)     AS tax_amount,
    TRY_TO_DECIMAL(TRIM(total_amount), 12, 2)                   AS total_amount,
    _loaded_at,
    _source_file
FROM RAW.RAW_ORDERS
WHERE order_id IS NOT NULL;

-- 4. STG_ORDER_ITEMS
CREATE OR REPLACE VIEW STAGING.STG_ORDER_ITEMS AS
SELECT
    TRIM(order_item_id)                                         AS order_item_id,
    TRIM(order_id)                                              AS order_id,
    TRIM(product_id)                                            AS product_id,
    TRY_TO_NUMBER(TRIM(quantity))                               AS quantity,
    TRY_TO_DECIMAL(TRIM(unit_price), 10, 2)                     AS unit_price,
    COALESCE(TRY_TO_DECIMAL(TRIM(discount_amount), 10, 2), 0.00) AS discount_amount,
    TRY_TO_DECIMAL(TRIM(total_price), 12, 2)                    AS total_price,
    _loaded_at,
    _source_file
FROM RAW.RAW_ORDER_ITEMS
WHERE order_item_id IS NOT NULL;

-- 5. STG_SHIPMENTS
CREATE OR REPLACE VIEW STAGING.STG_SHIPMENTS AS
SELECT
    TRIM(shipment_id)                                           AS shipment_id,
    TRIM(order_id)                                              AS order_id,
    UPPER(TRIM(shipping_carrier))                               AS shipping_carrier,
    TRIM(tracking_number)                                       AS tracking_number,
    UPPER(TRIM(shipment_status))                                AS shipment_status,
    TRY_TO_DATE(TRIM(shipped_date), 'DD-MM-YYYY')               AS shipped_date,
    TRY_TO_DATE(TRIM(delivered_date), 'DD-MM-YYYY')             AS delivered_date,
    TRY_TO_DATE(TRIM(estimated_arrival_date), 'DD-MM-YYYY')     AS estimated_arrival_date,
    _loaded_at,
    _source_file
FROM RAW.RAW_SHIPMENTS
WHERE shipment_id IS NOT NULL;

-- 6. STG_RETURNS
CREATE OR REPLACE VIEW STAGING.STG_RETURNS AS
SELECT
    TRIM(return_id)                                             AS return_id,
    TRIM(order_id)                                              AS order_id,
    TRIM(product_id)                                            AS product_id,
    TRY_TO_DATE(TRIM(return_date), 'DD-MM-YYYY')                AS return_date,
    INITCAP(TRIM(return_reason))                                AS return_reason,
    COALESCE(TRY_TO_DECIMAL(TRIM(refund_amount), 10, 2), 0.00)  AS refund_amount,
    UPPER(TRIM(return_status))                                  AS return_status,
    _loaded_at,
    _source_file
FROM RAW.RAW_RETURNS
WHERE return_id IS NOT NULL;
