-- ==============================================================================
-- 05_control / 01_audit_log_table.sql
-- Operational control and audit tables for monitoring ingestion runs and data volumes
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA CONTROL;

-- Ingestion and Pipeline Execution Log Table
CREATE TABLE IF NOT EXISTS CONTROL.PIPELINE_EXECUTION_LOG (
    execution_id            VARCHAR(36) DEFAULT UUID_STRING(),
    pipeline_name           VARCHAR(100) NOT NULL,
    layer_name              VARCHAR(50) NOT NULL,    -- RAW, STAGING, CURATED, MART
    status                  VARCHAR(20) NOT NULL,    -- STARTED, SUCCESS, FAILED
    rows_processed          NUMBER DEFAULT 0,
    rows_rejected           NUMBER DEFAULT 0,
    started_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    completed_at            TIMESTAMP_NTZ,
    execution_duration_sec  NUMBER,
    error_message           VARCHAR(2000),
    executed_by_user        VARCHAR(100) DEFAULT CURRENT_USER(),
    warehouse_used          VARCHAR(100) DEFAULT CURRENT_WAREHOUSE()
);

-- Operational Data Quality Row Count Audit Table
CREATE TABLE IF NOT EXISTS CONTROL.DATA_QUALITY_AUDIT (
    audit_id                VARCHAR(36) DEFAULT UUID_STRING(),
    check_timestamp         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    target_schema           VARCHAR(50),
    target_table            VARCHAR(100),
    metric_name             VARCHAR(100),            -- ROW_COUNT, NULL_KEYS, DUPLICATES
    metric_value            NUMBER,
    check_status            VARCHAR(20),             -- PASS, WARN, FAIL
    notes                   VARCHAR(500)
);
