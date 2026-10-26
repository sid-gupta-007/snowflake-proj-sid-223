-- ==============================================================================
-- 04_mart / 02_product_mart.sql
-- Product and Category Performance Analytics View
-- ==============================================================================

USE DATABASE RETAIL_DB;
USE SCHEMA MART;

CREATE OR REPLACE VIEW MART.MART_PRODUCT_PERFORMANCE AS
WITH item_sales AS (
    SELECT
        oi.product_key,
        COUNT(DISTINCT oi.order_id_nk)                          AS orders_containing_product,
        SUM(oi.quantity)                                        AS total_quantity_sold,
        SUM(oi.gross_line_total)                                AS total_gross_sales,
        SUM(oi.discount_amount)                                 AS total_discount_given,
        SUM(oi.calculated_line_total)                           AS total_net_sales,
        SUM(oi.total_cost)                                      AS total_cost_of_goods_sold,
        SUM(oi.gross_profit)                                    AS total_gross_profit
    FROM CURATED.FACT_ORDER_ITEMS oi
    GROUP BY oi.product_key
),
product_returns AS (
    SELECT
        r.product_key,
        COUNT(DISTINCT r.return_id_nk)                          AS total_units_returned,
        SUM(r.refund_amount)                                    AS total_refunds_issued
    FROM CURATED.FACT_RETURNS r
    GROUP BY r.product_key
)
SELECT
    p.product_id_nk                                             AS product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.sku,
    p.unit_cost,
    p.unit_price,
    p.gross_margin_pct                                          AS catalog_margin_pct,
    COALESCE(s.orders_containing_product, 0)                    AS order_count,
    COALESCE(s.total_quantity_sold, 0)                          AS units_sold,
    COALESCE(s.total_net_sales, 0.00)                           AS net_sales,
    COALESCE(s.total_gross_profit, 0.00)                        AS realized_gross_profit,
    ROUND(
        (COALESCE(s.total_gross_profit, 0.00) / NULLIF(COALESCE(s.total_net_sales, 0.00), 0)) * 100, 
        2
    )                                                           AS realized_profit_margin_pct,
    COALESCE(r.total_units_returned, 0)                         AS units_returned,
    COALESCE(r.total_refunds_issued, 0.00)                      AS refunds_issued,
    ROUND(
        (COALESCE(r.total_units_returned, 0) / NULLIF(COALESCE(s.total_quantity_sold, 0), 0)) * 100, 
        2
    )                                                           AS return_rate_pct
FROM CURATED.DIM_PRODUCT p
LEFT JOIN item_sales s ON p.product_key = s.product_key
LEFT JOIN product_returns r ON p.product_key = r.product_key;
