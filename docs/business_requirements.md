# Business Problem, Objectives & Requirements

## 1. Executive Summary
Modern omni-channel retail enterprises generate high-velocity transaction, fulfillment, and customer interaction data across disparate channels. To optimize margins, reduce return rates, maintain carrier SLAs, and maximize Customer Lifetime Value (LTV), leadership requires a consolidated, single-source-of-truth analytics platform.

This project implements the **Snowflake Power Retail Analytics Platform**, architected on Snowflake and developed/orchestrated within Google Antigravity.

---

## 2. Business Objectives
1. **Revenue & Profitability Intelligence**: Real-time visibility into Gross Revenue, Net Sales, Discounts, Cost of Goods Sold (COGS), and realized Gross Profit Margin across all sales channels.
2. **Customer 360 & Retention**: Segmenting customers into VIP, Repeat, and One-Time cohorts; tracking recency, frequency, and monetary (RFM) metrics to increase repeat purchase frequency.
3. **Product Performance & Merchandising**: Identifying high-margin vs high-return inventory to refine assortment planning and product pricing strategies.
4. **Logistics & Delivery SLAs**: Evaluating carrier fulfillment performance, transit times, and on-time delivery rates to reduce customer churn caused by shipping delays.
5. **Returns Diagnostics**: Quantifying refund leakages, analyzing top root causes for returns, and flagging categories with anomalous return rates.

---

## 3. Data Ingestion & Architecture Standards
- **Platform**: Snowflake Cloud Data Platform
- **Database**: `RETAIL_DB`
- **Schemas**:
  - `RAW`: Landing and transient staging of raw CSV data loaded via internal stage.
  - `STAGING`: Cleansed, typed, and standardized views (DD-MM-YYYY dates parsed, whitespace trimmed, safe casting).
  - `CURATED`: Star-schema dimensional model with surrogate keys (`MD5`), conforming dimensions, and fact tables.
  - `MART`: Aggregated, denormalized reporting views optimized for low-latency BI and dashboard queries.
  - `CONTROL`: Operational tracking, pipeline run audits, and CDC streams/tasks.
- **Source Files (6 datasets)**:
  1. `customers.csv`
  2. `products.csv`
  3. `orders.csv`
  4. `order_items.csv`
  5. `shipments.csv`
  6. `returns.csv`
