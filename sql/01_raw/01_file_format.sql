-- ==============================================================================
-- 01_raw / 01_file_format.sql
-- Create standard CSV file format in RAW schema
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA RAW;

CREATE OR REPLACE FILE FORMAT RAW.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    DATE_FORMAT = 'DD-MM-YYYY'
    TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS'
    TRIM_SPACE = TRUE
    NULL_IF = ('NULL', 'null', '', 'N/A', 'NA', '\\N')
    EMPTY_FIELD_AS_NULL = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Standard CSV file format with DD-MM-YYYY date parsing and header skipping';
