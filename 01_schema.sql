-- Week 6 | SQL DE Pipeline | MySQL 8.0+
DROP DATABASE IF EXISTS de_pipeline;
CREATE DATABASE de_pipeline;
USE de_pipeline;

-- 1) Staging table: raw landing zone, no keys, so bulk load is fast
CREATE TABLE stg_customers (
    customer_id INT, name VARCHAR(100), email VARCHAR(150), city VARCHAR(50)
);

-- 2) Dimension table: one current row per customer
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150),
    city        VARCHAR(50),
    updated_at  TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

-- 3) Fact table: RANGE partitioned by month.
--    Every UNIQUE/PRIMARY key must include the partition column (order_date).
CREATE TABLE fact_orders (
    order_id    BIGINT        NOT NULL,
    customer_id INT           NOT NULL,
    order_date  DATE          NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    status      VARCHAR(20)   NOT NULL,
    PRIMARY KEY (order_id, order_date)
)
PARTITION BY RANGE COLUMNS (order_date) (
    PARTITION p2026_01 VALUES LESS THAN ('2026-02-01'),
    PARTITION p2026_02 VALUES LESS THAN ('2026-03-01'),
    PARTITION p2026_03 VALUES LESS THAN ('2026-04-01'),
    PARTITION p2026_04 VALUES LESS THAN ('2026-05-01'),
    PARTITION p2026_05 VALUES LESS THAN ('2026-06-01'),
    PARTITION p2026_06 VALUES LESS THAN ('2026-07-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)   -- catch-all
);
