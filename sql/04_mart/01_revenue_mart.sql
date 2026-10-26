-- ==============================================================================
-- 04_mart / 01_revenue_mart.sql
-- Business-Ready Revenue & Order Performance View
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA MART;

CREATE OR REPLACE VIEW MART.MART_REVENUE_METRICS AS
SELECT
    d.year_num,
    d.quarter_name,
    d.month_num,
    d.month_name,
    d.calendar_date,
    o.channel,
    o.payment_method,
    o.order_status,
    COUNT(DISTINCT o.order_id_nk)                                AS total_orders,
    COUNT(DISTINCT o.customer_key)                               AS unique_transacting_customers,
    SUM(o.total_amount)                                          AS gross_revenue,
    SUM(o.net_sales_amount)                                      AS net_sales,
    SUM(o.shipping_fee)                                          AS total_shipping_revenue,
    SUM(o.tax_amount)                                            AS total_tax_collected,
    ROUND(AVG(o.total_amount), 2)                                AS average_order_value (aov),
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT o.customer_key), 0), 2) AS revenue_per_customer
FROM CURATED.FACT_ORDERS o
LEFT JOIN CURATED.DIM_DATE d ON o.order_date_key = d.date_key
GROUP BY 
    d.year_num, d.quarter_name, d.month_num, d.month_name, d.calendar_date,
    o.channel, o.payment_method, o.order_status;
