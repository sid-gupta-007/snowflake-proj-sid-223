-- ==============================================================================
-- 04_mart / 03_customer_mart.sql
-- Customer 360 and Lifetime Value (LTV) Analytics View
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA MART;

CREATE OR REPLACE VIEW MART.MART_CUSTOMER_INSIGHTS AS
WITH customer_orders AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_id_nk)                             AS total_orders,
        MIN(order_date)                                         AS first_order_date,
        MAX(order_date)                                         AS most_recent_order_date,
        SUM(total_amount)                                       AS lifetime_spend,
        ROUND(AVG(total_amount), 2)                             AS avg_order_value,
        SUM(shipping_fee)                                       AS total_shipping_paid
    FROM CURATED.FACT_ORDERS
    GROUP BY customer_key
),
customer_returns AS (
    SELECT
        o.customer_key,
        COUNT(DISTINCT r.return_id_nk)                          AS total_returns,
        SUM(r.refund_amount)                                    AS total_refunded_amount
    FROM CURATED.FACT_RETURNS r
    JOIN CURATED.FACT_ORDERS o ON r.order_key = o.order_key
    GROUP BY o.customer_key
)
SELECT
    c.customer_id_nk                                            AS customer_id,
    c.full_name,
    c.email,
    c.city,
    c.state,
    c.country,
    c.signup_date,
    COALESCE(co.total_orders, 0)                                AS lifetime_orders,
    co.first_order_date,
    co.most_recent_order_date,
    DATEDIFF(day, co.most_recent_order_date, CURRENT_DATE())    AS days_since_last_order,
    COALESCE(co.lifetime_spend, 0.00)                           AS lifetime_spend,
    COALESCE(co.avg_order_value, 0.00)                          AS average_order_value,
    COALESCE(cr.total_returns, 0)                               AS lifetime_returns,
    COALESCE(cr.total_refunded_amount, 0.00)                    AS lifetime_refunded,
    CASE 
        WHEN COALESCE(co.total_orders, 0) >= 5 AND co.lifetime_spend >= 1000 THEN 'VIP'
        WHEN COALESCE(co.total_orders, 0) >= 2 THEN 'Repeat'
        WHEN COALESCE(co.total_orders, 0) = 1 THEN 'One-Time'
        ELSE 'Prospect (No Orders)'
    END                                                         AS customer_segment
FROM CURATED.DIM_CUSTOMER c
LEFT JOIN customer_orders co ON c.customer_key = co.customer_key
LEFT JOIN customer_returns cr ON c.customer_key = cr.customer_key;
