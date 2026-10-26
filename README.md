# Snowflake Power Retail Analytics Platform

Enterprise-grade, end-to-end retail intelligence platform architected on **Snowflake Cloud Data Platform** and orchestrated through **Google Antigravity**.

---

## 🏛️ Architecture Overview

```
Google Antigravity (AI Orchestrator)
        │
        ▼ (Snowflake Python Connector)
┌────────────────────────────────────────────────────────────────────────┐
│                        Snowflake (RETAIL_DB)                           │
│                                                                        │
│   RAW         ──►  STAGING       ──►  CURATED       ──►  MART          │
│  (CSV Load)       (Casting/Clean)    (Star Schema)     (Analytics)     │
│       ▲                                                     │          │
│       │                                                     ▼          │
│  @RETAIL_STAGE                                          Streamlit      │
│  RAW.CSV_FORMAT                                         Dashboard      │
│                                                                        │
│   CONTROL: Ingestion Audits, Row-Count Logs, Streams & Tasks           │
└────────────────────────────────────────────────────────────────────────┘
```

The database `RETAIL_DB` is divided into five logical schemas:
1. **`RAW`**: Loaded CSV data via named internal stage `@RAW.RETAIL_STAGE` and file format `RAW.CSV_FORMAT`.
2. **`STAGING`**: Type conversions (`TRY_TO_DATE`, `TRY_TO_DECIMAL`), standardized text casing, trimmed whitespace, and filtered null primary keys.
3. **`CURATED`**: Conformed dimensional model (`DIM_CUSTOMER`, `DIM_PRODUCT`, `DIM_DATE`) and fact tables (`FACT_ORDERS`, `FACT_ORDER_ITEMS`, `FACT_SHIPMENTS`, `FACT_RETURNS`).
4. **`MART`**: Optimized analytics views (`MART_REVENUE_METRICS`, `MART_PRODUCT_PERFORMANCE`, `MART_CUSTOMER_INSIGHTS`, `MART_SHIPPING_FULFILLMENT`, `MART_RETURNS_ANALYSIS`).
5. **`CONTROL`**: Operational logging (`PIPELINE_EXECUTION_LOG`, `DATA_QUALITY_AUDIT`), change data capture streams, and automated audit tasks.

---

## 📂 Project Structure

```
snowflake-proj/
├── .env.example               # Template for Snowflake credentials & auth
├── .gitignore                 # Enforces security: ignores .env, keys, & local data
├── requirements.txt           # Python dependencies
├── README.md                  # This file
├── data/                      # Directory for the 6 retail CSV files
│   └── README.md
├── docs/                      # Comprehensive technical documentation
│   ├── business_requirements.md
│   └── dimensional_model.md
├── sql/                       # Modular, ordered SQL migrations
│   ├── 00_setup/              # Warehouse, Database, Schemas DDL
│   ├── 01_raw/                # Stage, File Format, Raw Tables, COPY INTO & Validation
│   ├── 02_staging/            # Staging views with safe conversions
│   ├── 03_curated/            # Dimensions & Fact tables
│   ├── 04_mart/               # Business analytics reporting views
│   └── 05_control/            # Pipeline audit logs, streams & tasks
├── src/                       # Orchestration & Snowflake connector utilities
│   ├── config.py              # Environment configuration loader
│   ├── snowflake_client.py    # Key-pair & password connector with masked logging
│   └── runner.py              # Safe migration runner CLI
├── app/                       # Streamlit application
│   └── app.py                 # Multi-view Executive KPI & Analytics Dashboard
└── tests/                     # Unit test suites (Local tests without Snowflake connection)
    └── test_local_syntax.py
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 2. Configure Snowflake Credentials
Copy `.env.example` to `.env`:
```powershell
cp .env.example .env
```
Open `.env` and fill in your Snowflake account details:
- `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier (e.g., `xyz12345.us-east-1` or `orgname-accountname`).
- `SNOWFLAKE_USER`: Your username.
- `SNOWFLAKE_ROLE`: Role with database and warehouse creation privileges (e.g., `ACCOUNTADMIN` or `SYSADMIN`).
- `SNOWFLAKE_WAREHOUSE`: `COMPUTE_WH`.
- `SNOWFLAKE_DATABASE`: `RETAIL_DB`.
- `SNOWFLAKE_AUTH_TYPE`: `PASSWORD` or `KEYPAIR`.
- `SNOWFLAKE_PASSWORD`: Your password (if using password auth).

> [!NOTE]
> For production environments, Key-Pair authentication (`SNOWFLAKE_AUTH_TYPE=KEYPAIR` with `SNOWFLAKE_PRIVATE_KEY_PATH`) is recommended.

### 3. Test Connection
Run a non-destructive connection test:
```powershell
python src/runner.py --test
```

### 4. Provide the 6 Source CSV Files
Place the following files in the `data/` folder:
- `customers.csv`
- `products.csv`
- `orders.csv`
- `order_items.csv`
- `shipments.csv`
- `returns.csv`

### 5. Execute Migrations & Ingestion
Deploy all SQL stages in order:
```powershell
python src/runner.py --stage all
```
Or run individual stages incrementally:
```powershell
python src/runner.py --stage 00_setup
python src/runner.py --stage 01_raw
python src/runner.py --stage 02_staging
python src/runner.py --stage 03_curated
python src/runner.py --stage 04_mart
python src/runner.py --stage 05_control
```

### 6. Launch the Streamlit Analytics Dashboard
```powershell
python -m streamlit run app/app.py
```
Open your browser at `http://localhost:8501`.

---

## ⚡ Performance Optimization & Clustering
- **Date Partitioning / Clustering**: For large fact tables (`FACT_ORDERS` and `FACT_ORDER_ITEMS`), cluster by `order_date_key` to optimize date-range queries:
  ```sql
  ALTER TABLE CURATED.FACT_ORDERS CLUSTER BY (order_date_key);
  ALTER TABLE CURATED.FACT_ORDER_ITEMS CLUSTER BY (order_date_key);
  ```
- **Auto-Suspension**: Virtual warehouse `COMPUTE_WH` is configured with `AUTO_SUSPEND = 60` seconds to minimize Snowflake compute credit consumption when idle.
- **Micro-Partition Pruning**: The `MART` layer views leverage predicate pushdown on conformed dimension keys.
