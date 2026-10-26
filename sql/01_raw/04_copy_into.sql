-- ==============================================================================
-- 01_raw / 04_copy_into.sql
-- Ingestion commands to load the six CSV files from @RAW.RETAIL_STAGE
-- Includes metadata tracking: METADATA$FILENAME and CURRENT_TIMESTAMP()
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA RAW;

-- 1. Ingest Customers
COPY INTO RAW.RAW_CUSTOMERS (
    customer_id, first_name, last_name, email, phone, 
    address, city, state, zip_code, country, signup_date, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, t.$5, 
        t.$6, t.$7, t.$8, t.$9, t.$10, t.$11,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/customers.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 2. Ingest Products
COPY INTO RAW.RAW_PRODUCTS (
    product_id, product_name, category, subcategory, 
    unit_cost, unit_price, sku, is_active, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, 
        t.$5, t.$6, t.$7, t.$8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/products.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 3. Ingest Orders
COPY INTO RAW.RAW_ORDERS (
    order_id, customer_id, order_date, order_status, 
    channel, payment_method, shipping_fee, tax_amount, total_amount, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, 
        t.$5, t.$6, t.$7, t.$8, t.$9,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/orders.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 4. Ingest Order Items
COPY INTO RAW.RAW_ORDER_ITEMS (
    order_item_id, order_id, product_id, quantity, 
    unit_price, discount_amount, total_price, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, 
        t.$5, t.$6, t.$7,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/order_items.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 5. Ingest Shipments
COPY INTO RAW.RAW_SHIPMENTS (
    shipment_id, order_id, shipping_carrier, tracking_number, 
    shipment_status, shipped_date, delivered_date, estimated_arrival_date, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, 
        t.$5, t.$6, t.$7, t.$8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/shipments.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 6. Ingest Returns
COPY INTO RAW.RAW_RETURNS (
    return_id, order_id, product_id, return_date, 
    return_reason, refund_amount, return_status, 
    _loaded_at, _source_file
)
FROM (
    SELECT 
        t.$1, t.$2, t.$3, t.$4, 
        t.$5, t.$6, t.$7,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @RAW.RETAIL_STAGE/returns.csv t
)
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE';
