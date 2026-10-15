# SQL DE Pipeline (Week 6) — MySQL, beginner guide

## What you are building
A tiny "data warehouse load":
1. **Customers** arrive as CSV files on two days. Day 2 has some changed rows and some new rows. You load them into a staging table, then **merge** them into the clean `dim_customer` table.
2. **Orders** (200,000 rows) are bulk-loaded into `fact_orders`, which is split into **monthly partitions**.
3. You add **indexes** so lookups are fast, then check with `EXPLAIN` that MySQL actually uses the partitions and indexes.

## Folder contents
- `data/` holds the CSV files (already generated; no Python needed).
- `01_schema.sql` creates the database and tables.
- `02_load_customers_day1.sql` and `02_load_customers_day2.sql` load and merge customers.
- `03_load_orders.sql` bulk loads orders.
- `04_indexes.sql` creates the indexes.
- `05_verify.sql` proves everything worked.
- `run_all.sql` runs all of the above in order.
- `generate_data.py` regenerates the CSVs (optional).

## One-time setup (Mac)
Open the **Terminal** app and run:
```bash
brew install mysql
brew services start mysql
mysql -u root -e "SET GLOBAL local_infile = 1;"
```

## Run in VS Code
1. VS Code -> **File -> Open Folder** -> choose the unzipped `sql_de_pipeline_mysql` folder.
2. Open the terminal inside VS Code: menu **Terminal -> New Terminal**. It opens already inside your project folder.
3. Run the whole project with one command:
   ```bash
   mysql -u root --local-infile=1 -t < run_all.sql
   ```
4. To save the output for screenshots or your write-up:
   ```bash
   mysql -u root --local-infile=1 -t < run_all.sql > output.txt
   ```
   `output.txt` appears in the VS Code file list. Click it to open it.

Or run the steps one by one (same terminal) to see each result:
```bash
mysql -u root --local-infile=1 -t < 01_schema.sql
mysql -u root --local-infile=1 -t < 02_load_customers_day1.sql
mysql -u root --local-infile=1 -t < 02_load_customers_day2.sql
mysql -u root --local-infile=1 -t < 03_load_orders.sql
mysql -u root --local-infile=1 -t < 04_indexes.sql
mysql -u root --local-infile=1 -t < 05_verify.sql
```

## What you should see
- Day 1: `rows_inserted = 5000`
- Day 2: `rows_updated = 200`, `rows_inserted = 100`, `dim_rows = 5100`
- Orders: about 33,000 rows in each partition `p2026_01` to `p2026_06`, and 0 in `p_future`.
- Verify:
  - A: new = 100, updated = 200, total = 5100.
  - B: the `partitions` column shows only `p2026_03`.
  - C: the `key` column shows `idx_orders_cust_date`.
  - D: the `key` column shows `idx_orders_status_date`.

## Explore the data yourself
```bash
mysql -u root de_pipeline
```
Then try `SHOW TABLES;` and `SELECT * FROM dim_customer LIMIT 5;`. Type `exit` to leave.

## Common errors
- **Loading local data is disabled**: run the `SET GLOBAL local_infile = 1;` command above and keep `--local-infile=1` in every command.
- **Can't connect to local MySQL server**: run `brew services start mysql` and wait 5 seconds.
- **File 'data/...csv' not found**: your terminal is in the wrong folder. Run `pwd`; it must end with `sql_de_pipeline_mysql`.
- **Access denied for user root**: you set a root password. Add `-p` to the mysql commands and type it when asked.

## MySQL differences to know
- MySQL has no `MERGE`, so the merge is an `UPDATE ... JOIN` plus an `INSERT ... LEFT JOIN`.
- MySQL has no `COPY`, so we use `LOAD DATA LOCAL INFILE`.
- MySQL has no partial indexes, so we use a composite `(status, order_date)` index instead.
