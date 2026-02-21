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
-- --------------------------------------------------------

-- Optional: Test index improvement
-- CREATE INDEX idx_orders_total_amount ON orders(total_amount DESC);
-- EXPLAIN ANALYZE
-- SELECT order_id, customer_id, total_amount, status
-- FROM orders
-- ORDER BY total_amount DESC
-- LIMIT 10;
