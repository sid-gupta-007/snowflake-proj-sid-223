-- ==============================================================================
-- 01_raw / 05_raw_validation.sql
-- Validation scripts for RAW layer: row counts, null keys, and load status
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA RAW;

-- 1. Table Row Counts & Source File Distribution
SELECT 'RAW_CUSTOMERS' AS table_name, COUNT(*) AS row_count, COUNT(DISTINCT _source_file) AS file_count FROM RAW.RAW_CUSTOMERS
UNION ALL
SELECT 'RAW_PRODUCTS', COUNT(*), COUNT(DISTINCT _source_file) FROM RAW.RAW_PRODUCTS
UNION ALL
SELECT 'RAW_ORDERS', COUNT(*), COUNT(DISTINCT _source_file) FROM RAW.RAW_ORDERS
UNION ALL
SELECT 'RAW_ORDER_ITEMS', COUNT(*), COUNT(DISTINCT _source_file) FROM RAW.RAW_ORDER_ITEMS
UNION ALL
SELECT 'RAW_SHIPMENTS', COUNT(*), COUNT(DISTINCT _source_file) FROM RAW.RAW_SHIPMENTS
UNION ALL
SELECT 'RAW_RETURNS', COUNT(*), COUNT(DISTINCT _source_file) FROM RAW.RAW_RETURNS;

-- 2. Primary Key Null Checks
SELECT 'RAW_CUSTOMERS' AS table_name, COUNT(*) AS null_primary_keys FROM RAW.RAW_CUSTOMERS WHERE customer_id IS NULL
UNION ALL
SELECT 'RAW_PRODUCTS', COUNT(*) FROM RAW.RAW_PRODUCTS WHERE product_id IS NULL
UNION ALL
SELECT 'RAW_ORDERS', COUNT(*) FROM RAW.RAW_ORDERS WHERE order_id IS NULL
UNION ALL
SELECT 'RAW_ORDER_ITEMS', COUNT(*) FROM RAW.RAW_ORDER_ITEMS WHERE order_item_id IS NULL
UNION ALL
SELECT 'RAW_SHIPMENTS', COUNT(*) FROM RAW.RAW_SHIPMENTS WHERE shipment_id IS NULL
UNION ALL
SELECT 'RAW_RETURNS', COUNT(*) FROM RAW.RAW_RETURNS WHERE return_id IS NULL;

-- 3. Copy History Inspection (past 24 hours)
SELECT 
    table_name,
    file_name,
    status,
    row_count,
    row_parsed,
    error_count,
    first_error_message,
    last_load_time
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW_ORDERS',
    START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
));
