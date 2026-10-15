-- Bulk load the fact table BEFORE creating secondary indexes (faster)
USE de_pipeline;

LOAD DATA LOCAL INFILE 'data/orders.csv'
INTO TABLE fact_orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ANALYZE TABLE fact_orders;

-- Rows per partition (p_future should be 0)
SELECT PARTITION_NAME AS 'partition', TABLE_ROWS AS approx_rows
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = 'de_pipeline' AND TABLE_NAME = 'fact_orders'
ORDER BY PARTITION_ORDINAL_POSITION;
