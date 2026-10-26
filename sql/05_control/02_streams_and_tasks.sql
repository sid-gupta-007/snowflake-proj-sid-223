-- ==============================================================================
-- 05_control / 02_streams_and_tasks.sql
-- Change Data Capture (CDC) Streams and Scheduled Tasks for Operational Control
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA CONTROL;

-- CDC Stream on RAW_ORDERS to track newly arrived orders
CREATE OR REPLACE STREAM CONTROL.RAW_ORDERS_STREAM 
ON TABLE RAW.RAW_ORDERS
APPEND_ONLY = TRUE
COMMENT = 'Captures append-only inserts to RAW_ORDERS for automated downstream processing';

-- Scheduled Daily Maintenance / Audit Task (Sample operational task template)
-- Suspended by default to prevent unintended compute costs
CREATE OR REPLACE TASK CONTROL.DAILY_DATA_QUALITY_AUDIT_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 2 * * * UTC' -- Daily at 2 AM UTC
    COMMENT = 'Automated daily data quality check recording row counts to CONTROL.DATA_QUALITY_AUDIT'
AS
INSERT INTO CONTROL.DATA_QUALITY_AUDIT (target_schema, target_table, metric_name, metric_value, check_status)
SELECT 'RAW', 'RAW_ORDERS', 'ROW_COUNT', COUNT(*), 'PASS' FROM RAW.RAW_ORDERS;

-- Note: Tasks are created in SUSPENDED state by default.
-- To resume: ALTER TASK CONTROL.DAILY_DATA_QUALITY_AUDIT_TASK RESUME;
