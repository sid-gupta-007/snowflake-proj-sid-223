-- ==============================================================================
-- 04_mart / 05_returns_mart.sql
-- Returns & Refund Diagnostics View
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA MART;

CREATE OR REPLACE VIEW MART.MART_RETURNS_ANALYSIS AS
SELECT
    p.category,
    p.subcategory,
    r.return_reason,
    r.return_status,
    COUNT(DISTINCT r.return_id_nk)                              AS return_count,
    SUM(r.refund_amount)                                        AS total_refunded_amount,
    ROUND(AVG(r.refund_amount), 2)                              AS avg_refund_per_return
FROM CURATED.FACT_RETURNS r
LEFT JOIN CURATED.DIM_PRODUCT p ON r.product_key = p.product_key
GROUP BY p.category, p.subcategory, r.return_reason, r.return_status;
