-- ==============================================================================
-- 01_raw / 03_raw_tables.sql
-- Table definitions for the six raw datasets in RAW schema.
-- NOTE: In line with engineering guidelines, these definitions use standard
-- industry column patterns for retail and will be finalized once the actual 
-- CSV source headers are confirmed.
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA RAW;

-- 1. Customers Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_CUSTOMERS (
    raw_payload             VARIANT,           -- Optional: if ingesting full payload
    customer_id             VARCHAR(100),
    first_name              VARCHAR(100),
    last_name               VARCHAR(100),
    email                   VARCHAR(255),
    phone                   VARCHAR(50),
    address                 VARCHAR(255),
    city                    VARCHAR(100),
    state                   VARCHAR(50),
    zip_code                VARCHAR(20),
    country                 VARCHAR(50),
    signup_date             VARCHAR(50),       -- Stored as raw string, converted in STAGING
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);

-- 2. Products Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_PRODUCTS (
    product_id              VARCHAR(100),
    product_name            VARCHAR(255),
    category                VARCHAR(100),
    subcategory             VARCHAR(100),
    unit_cost               VARCHAR(50),
    unit_price              VARCHAR(50),
    sku                     VARCHAR(100),
    is_active               VARCHAR(20),
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);

-- 3. Orders Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_ORDERS (
    order_id                VARCHAR(100),
    customer_id             VARCHAR(100),
    order_date              VARCHAR(50),       -- In DD-MM-YYYY format
    order_status            VARCHAR(50),
    channel                 VARCHAR(50),
    payment_method          VARCHAR(50),
    shipping_fee            VARCHAR(50),
    tax_amount              VARCHAR(50),
    total_amount            VARCHAR(50),
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);

-- 4. Order Items Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_ORDER_ITEMS (
    order_item_id           VARCHAR(100),
    order_id                VARCHAR(100),
    product_id              VARCHAR(100),
    quantity                VARCHAR(50),
    unit_price              VARCHAR(50),
    discount_amount         VARCHAR(50),
    total_price             VARCHAR(50),
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);

-- 5. Shipments Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_SHIPMENTS (
    shipment_id             VARCHAR(100),
    order_id                VARCHAR(100),
    shipping_carrier        VARCHAR(100),
    tracking_number         VARCHAR(100),
    shipment_status         VARCHAR(50),
    shipped_date            VARCHAR(50),       -- In DD-MM-YYYY format
    delivered_date          VARCHAR(50),       -- In DD-MM-YYYY format
    estimated_arrival_date  VARCHAR(50),
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);

-- 6. Returns Raw Table
CREATE TABLE IF NOT EXISTS RAW.RAW_RETURNS (
    return_id               VARCHAR(100),
    order_id                VARCHAR(100),
    product_id              VARCHAR(100),
    return_date             VARCHAR(50),       -- In DD-MM-YYYY format
    return_reason           VARCHAR(255),
    refund_amount           VARCHAR(50),
    return_status           VARCHAR(50),
    _loaded_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file            VARCHAR(255)
);
