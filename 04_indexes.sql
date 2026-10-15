USE de_pipeline;

-- Composite index: "all orders for a customer, newest first"
CREATE INDEX idx_orders_cust_date ON fact_orders (customer_id, order_date DESC);

-- MySQL has NO partial indexes (no CREATE INDEX ... WHERE).
-- Closest practical equivalent: a composite index that leads with the filter column.
CREATE INDEX idx_orders_status_date ON fact_orders (status, order_date);

ANALYZE TABLE fact_orders;

SELECT index_name, ROUND(stat_value * @@innodb_page_size / 1024) AS size_kb
FROM mysql.innodb_index_stats
WHERE database_name = 'de_pipeline' AND table_name LIKE 'fact_orders#p#p2026_03'
  AND stat_name = 'size';
