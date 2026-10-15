-- Day 1 customer load: staging -> "MERGE" into dimension
-- (MySQL has no MERGE statement, so we emulate it with UPDATE-join + INSERT-anti-join)
USE de_pipeline;

TRUNCATE stg_customers;
LOAD DATA LOCAL INFILE 'data/customers_day1.csv'
INTO TABLE stg_customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

START TRANSACTION;

-- WHEN MATCHED AND changed THEN UPDATE   (<=> is NULL-safe equality)
UPDATE dim_customer d
JOIN stg_customers s ON s.customer_id = d.customer_id
SET d.name = s.name, d.email = s.email, d.city = s.city, d.updated_at = NOW(6)
WHERE NOT (d.name <=> s.name AND d.email <=> s.email AND d.city <=> s.city);
SELECT ROW_COUNT() AS rows_updated;

-- WHEN NOT MATCHED THEN INSERT
INSERT INTO dim_customer (customer_id, name, email, city)
SELECT s.customer_id, s.name, s.email, s.city
FROM stg_customers s
LEFT JOIN dim_customer d ON d.customer_id = s.customer_id
WHERE d.customer_id IS NULL;
SELECT ROW_COUNT() AS rows_inserted;

COMMIT;

SELECT COUNT(*) AS dim_rows FROM dim_customer;
