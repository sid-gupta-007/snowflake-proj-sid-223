-- ==============================================================================
-- 00_setup / 02_database.sql
-- Create and set active database RETAIL_DB
-- ==============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE DATABASE IF NOT EXISTS RETAIL_DB
    COMMENT = 'Enterprise Retail Analytics Platform Database';

USE DATABASE RETAIL_DB;
