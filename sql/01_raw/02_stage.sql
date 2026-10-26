-- ==============================================================================
-- 01_raw / 02_stage.sql
-- Create internal named stage RAW.RETAIL_STAGE with RAW.CSV_FORMAT
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA RAW;

CREATE OR REPLACE STAGE RAW.RETAIL_STAGE
    FILE_FORMAT = RAW.CSV_FORMAT
    COMMENT = 'Internal stage for staging the 6 retail CSV files (Customers, Products, Orders, Order Items, Shipments, Returns)';

-- Verify stage creation
LIST @RAW.RETAIL_STAGE;
