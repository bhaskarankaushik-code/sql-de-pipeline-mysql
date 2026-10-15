-- Runs the whole project in order. Use:  mysql -u root --local-infile=1 -t < run_all.sql
SELECT '===== STEP 1: schema =====' AS step;
SOURCE 01_schema.sql;
SELECT '===== STEP 2: load customers day 1 =====' AS step;
SOURCE 02_load_customers_day1.sql;
SELECT '===== STEP 3: load customers day 2 =====' AS step;
SOURCE 02_load_customers_day2.sql;
SELECT '===== STEP 4: load 200k orders =====' AS step;
SOURCE 03_load_orders.sql;
SELECT '===== STEP 5: indexes =====' AS step;
SOURCE 04_indexes.sql;
SELECT '===== STEP 6: verify =====' AS step;
SOURCE 05_verify.sql;
