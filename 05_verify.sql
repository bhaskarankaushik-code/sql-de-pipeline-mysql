USE de_pipeline;

SELECT '--- A) MERGE check: expect 100 new, 200 updated, 5100 total' AS step;
SELECT SUM(customer_id > 5000) AS new_customers,
       SUM(customer_id <= 5000 AND updated_at > (SELECT MIN(updated_at) FROM dim_customer)) AS updated_customers,
       COUNT(*) AS total
FROM dim_customer;

SELECT '--- B) Partition pruning: "partitions" column should show ONLY p2026_03' AS step;
EXPLAIN SELECT COUNT(*) FROM fact_orders
WHERE order_date >= '2026-03-01' AND order_date < '2026-04-01';

SELECT '--- C) Composite index: key should be idx_orders_cust_date' AS step;
EXPLAIN SELECT * FROM fact_orders
WHERE customer_id = 42 AND order_date >= '2026-02-01' ORDER BY order_date DESC;

SELECT '--- D) Status+date index: key should be idx_orders_status_date' AS step;
EXPLAIN SELECT * FROM fact_orders
WHERE status = 'PENDING' AND order_date >= '2026-06-01';
