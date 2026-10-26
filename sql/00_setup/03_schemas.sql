-- ==============================================================================
-- 00_setup / 03_schemas.sql
-- Create the 5 core architectural schemas in RETAIL_DB
-- ==============================================================================

USE DATABASE RETAIL_DB;

-- Schema 1: RAW - Original loaded CSV data directly from internal stage
CREATE SCHEMA IF NOT EXISTS RAW
    COMMENT = 'Ingestion layer containing raw unmanipulated data from CSV files';

-- Schema 2: STAGING - Cleaned, type-converted and standardized records
CREATE SCHEMA IF NOT EXISTS STAGING
    COMMENT = 'Staging layer with safe type conversions, trimmed strings, and DD-MM-YYYY dates';

-- Schema 3: CURATED - Star and Snowflake dimensional model (Facts and Dimensions)
CREATE SCHEMA IF NOT EXISTS CURATED
    COMMENT = 'Dimensional model layer with surrogate keys, grain definitions, and integrity';

-- Schema 4: MART - High-performance business-ready reporting views
CREATE SCHEMA IF NOT EXISTS MART
    COMMENT = 'Aggregated metrics and analytical views for dashboards and business users';

-- Schema 5: CONTROL - Ingestion audit logs, operational metadata, streams & tasks
CREATE SCHEMA IF NOT EXISTS CONTROL
    COMMENT = 'Operational metadata, audit tables, streams, and pipeline orchestration tasks';
