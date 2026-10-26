-- ==============================================================================
-- 04_mart / 04_shipping_mart.sql
-- Logistics, Carrier Fulfillment and Shipping Performance Analytics
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA MART;

CREATE OR REPLACE VIEW MART.MART_SHIPPING_FULFILLMENT AS
SELECT
    s.shipping_carrier,
    s.shipment_status,
    COUNT(DISTINCT s.shipment_id_nk)                            AS total_shipments,
    ROUND(AVG(s.transit_days), 1)                               AS avg_transit_days,
    COUNT(CASE WHEN s.is_on_time_delivery = TRUE THEN 1 END)    AS on_time_shipment_count,
    COUNT(CASE WHEN s.is_on_time_delivery = FALSE THEN 1 END)   AS late_shipment_count,
    ROUND(
        (COUNT(CASE WHEN s.is_on_time_delivery = TRUE THEN 1 END) / 
         NULLIF(COUNT(CASE WHEN s.is_on_time_delivery IS NOT NULL THEN 1 END), 0)) * 100, 
        2
    )                                                           AS on_time_delivery_rate_pct
FROM CURATED.FACT_SHIPMENTS s
GROUP BY s.shipping_carrier, s.shipment_status;
