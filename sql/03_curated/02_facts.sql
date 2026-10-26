-- ==============================================================================
-- 03_curated / 02_facts.sql
-- Dimensional model: Fact tables with surrogate keys, measures, and grain
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA CURATED;

-- 1. FACT_ORDERS
-- Granularity: One record per individual customer order
CREATE OR REPLACE TABLE CURATED.FACT_ORDERS AS
SELECT
    MD5(o.order_id)                                            AS order_key,
    o.order_id                                                 AS order_id_nk,
    MD5(o.customer_id)                                         AS customer_key,
    TO_NUMBER(TO_CHAR(o.order_date, 'YYYYMMDD'))               AS order_date_key,
    o.order_date,
    o.order_status,
    o.channel,
    o.payment_method,
    o.shipping_fee,
    o.tax_amount,
    o.total_amount,
    ROUND(o.total_amount - o.shipping_fee - o.tax_amount, 2)   AS net_sales_amount,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_ORDERS o;

-- 2. FACT_ORDER_ITEMS
-- Granularity: One record per line item inside an order
CREATE OR REPLACE TABLE CURATED.FACT_ORDER_ITEMS AS
SELECT
    MD5(oi.order_item_id)                                      AS order_item_key,
    oi.order_item_id                                           AS order_item_id_nk,
    MD5(oi.order_id)                                           AS order_key,
    oi.order_id                                                AS order_id_nk,
    MD5(oi.product_id)                                         AS product_key,
    oi.product_id                                              AS product_id_nk,
    MD5(o.customer_id)                                         AS customer_key,
    TO_NUMBER(TO_CHAR(o.order_date, 'YYYYMMDD'))               AS order_date_key,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.total_price                                             AS gross_line_total,
    ROUND((oi.quantity * oi.unit_price) - oi.discount_amount, 2) AS calculated_line_total,
    ROUND(p.unit_cost * oi.quantity, 2)                       AS total_cost,
    ROUND(((oi.quantity * oi.unit_price) - oi.discount_amount) - (p.unit_cost * oi.quantity), 2) AS gross_profit,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_ORDER_ITEMS oi
LEFT JOIN STAGING.STG_ORDERS o ON oi.order_id = o.order_id
LEFT JOIN STAGING.STG_PRODUCTS p ON oi.product_id = p.product_id;

-- 3. FACT_SHIPMENTS
-- Granularity: One record per shipment package
CREATE OR REPLACE TABLE CURATED.FACT_SHIPMENTS AS
SELECT
    MD5(s.shipment_id)                                         AS shipment_key,
    s.shipment_id                                              AS shipment_id_nk,
    MD5(s.order_id)                                            AS order_key,
    s.order_id                                                 AS order_id_nk,
    TO_NUMBER(TO_CHAR(s.shipped_date, 'YYYYMMDD'))             AS shipped_date_key,
    TO_NUMBER(TO_CHAR(s.delivered_date, 'YYYYMMDD'))           AS delivered_date_key,
    s.shipping_carrier,
    s.tracking_number,
    s.shipment_status,
    s.shipped_date,
    s.delivered_date,
    s.estimated_arrival_date,
    DATEDIFF(day, s.shipped_date, s.delivered_date)            AS transit_days,
    CASE 
        WHEN s.delivered_date IS NOT NULL AND s.estimated_arrival_date IS NOT NULL 
        THEN (s.delivered_date <= s.estimated_arrival_date)
        ELSE NULL 
    END                                                        AS is_on_time_delivery,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_SHIPMENTS s;

-- 4. FACT_RETURNS
-- Granularity: One record per returned item
CREATE OR REPLACE TABLE CURATED.FACT_RETURNS AS
SELECT
    MD5(r.return_id)                                           AS return_key,
    r.return_id                                                AS return_id_nk,
    MD5(r.order_id)                                            AS order_key,
    r.order_id                                                 AS order_id_nk,
    MD5(r.product_id)                                         AS product_key,
    r.product_id                                               AS product_id_nk,
    TO_NUMBER(TO_CHAR(r.return_date, 'YYYYMMDD'))              AS return_date_key,
    r.return_date,
    r.return_reason,
    r.refund_amount,
    r.return_status,
    CURRENT_TIMESTAMP()                                        AS _dw_inserted_at
FROM STAGING.STG_RETURNS r;
