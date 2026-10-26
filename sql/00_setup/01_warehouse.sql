-- ==============================================================================
-- 00_setup / 01_warehouse.sql
-- Create or use virtual warehouse for retail analytics workloads
-- ==============================================================================

USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WITH 
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Virtual warehouse for Retail Analytics Platform ETL and Analytics';

USE WAREHOUSE COMPUTE_WH;
