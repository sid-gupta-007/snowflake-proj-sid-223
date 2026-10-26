# Source Data Directory

This directory is designated for the six raw retail CSV datasets:

1. `customers.csv`
2. `products.csv`
3. `orders.csv`
4. `order_items.csv`
5. `shipments.csv`
6. `returns.csv`

### File Format Requirements
As specified in the architecture:
- **Header**: Contains column headers in row 1 (skipped during ingestion)
- **Field delimiter**: Comma `,`
- **Field optionally enclosed by**: Double quote `"`
- **Date format**: `DD-MM-YYYY`
- **Whitespace**: Trimmed automatically
- **Null values**: Represented by empty fields or null string representations

### Instructions
Please place the six CSV files directly into this `data/` folder, or paste the first 5 rows / header lines of each CSV into the chat so we can validate exact column names and data types before executing the DDL scripts.
