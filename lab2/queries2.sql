-- Lab 2: Part 4 — Performance Awareness
-- Using EXPLAIN ANALYZE to check query performance

-- Query 5 — Top 10 highest-value orders with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT order_id, customer_id, total_amount, status
FROM orders
ORDER BY total_amount DESC
LIMIT 10;

-- ========================================
-- Notes based on your EXPLAIN ANALYZE output:
-- --------------------------------------------------------
-- Seq Scan on orders (reads all rows)
-- Sort Method: Top-N heapsort
-- Memory used: 26 kB
-- Rows returned: 10
-- Planning Time: 1.021 ms
-- Execution Time: 0.277 ms
-- Observation: Seq Scan reads all rows; fine for small tables. 
-- Optional Improvement for large tables: create an index on total_amount
-- CREATE INDEX idx_orders_total_amount ON orders(total_amount DESC);
-- Re-run EXPLAIN ANALYZE to compare execution times.

-- Output observed on psql:

-- Limit  (cost=28.65..28.67 rows=10 width=102) (actual time=0.187..0.193 rows=10 loops=1)
--   ->  Sort  (cost=28.65..30.12 rows=590 width=102) (actual time=0.183..0.186 rows=10 loops=1)
--         Sort Key: total_amount DESC
--         Sort Method: top-N heapsort  Memory: 26kB
--         ->  Seq Scan on orders  (cost=0.00..15.90 rows=590 width=102) (actual time=0.021..0.035 rows=30 loops=1)
-- Planning Time: 1.021 ms
-- Execution Time: 0.277 ms
-- --------------------------------------------------------

-- Optional: Test index improvement
-- CREATE INDEX idx_orders_total_amount ON orders(total_amount DESC);
-- EXPLAIN ANALYZE
-- SELECT order_id, customer_id, total_amount, status
-- FROM orders
-- ORDER BY total_amount DESC
-- LIMIT 10;

-- Output observed on psql:

-- Limit  (cost=28.65..28.67 rows=10 width=102) (actual time=0.187..0.193 rows=10 loops=1)
--   ->  Sort  (cost=28.65..30.12 rows=590 width=102) (actual time=0.183..0.186 rows=10 loops=1)
--         Sort Key: total_amount DESC
--         Sort Method: top-N heapsort  Memory: 26kB
--         ->  Seq Scan on orders  (cost=0.00..15.90 rows=590 width=102) (actual time=0.021..0.035 rows=30 loops=1)
-- Planning Time: 1.021 ms
-- Execution Time: 0.277 ms
