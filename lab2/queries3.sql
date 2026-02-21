-- Part 5 — AI Prompting for SQL
-- Lab 2: Learning to use AI tools effectively with SQL

-- ===============================
-- Pattern 1 — Explain a query you do not fully understand
-- Example query:
SELECT order_id,
       customer_id,
       total_amount,
       CASE
           WHEN total_amount > 10000 THEN 'URGENT'
           ELSE 'NORMAL'
       END AS priority
FROM orders
WHERE shipped_date IS NULL
ORDER BY total_amount DESC
LIMIT 5;

-- Explanation of CASE WHEN block:
-- 1. CASE starts a conditional statement, like an IF/ELSE in programming.
-- 2. WHEN total_amount > 10000 THEN 'URGENT' checks each row:
--       If the total_amount column is greater than 10000, it assigns the value 'URGENT' to the new column called priority.
-- 3. ELSE 'NORMAL' assigns 'NORMAL' to the priority column for any rows that did not satisfy the WHEN condition.
-- 4. END closes the CASE block.
-- 5. AS priority renames the resulting computed column to "priority".

-- What happens if ELSE is removed?
-- If ELSE is removed, any row not matching the WHEN condition will have NULL in the priority column.

-- Adding a third tier example:
-- For orders above 20000, we assign 'CRITICAL':
SELECT order_id,
       customer_id,
       total_amount,
       CASE
           WHEN total_amount > 20000 THEN 'CRITICAL'
           WHEN total_amount > 10000 THEN 'URGENT'
           ELSE 'NORMAL'
       END AS priority
FROM orders
WHERE shipped_date IS NULL
ORDER BY total_amount DESC
LIMIT 5;

-- Experiment to learn:
-- Change the condition threshold (e.g., total_amount > 5000) and see how the priority changes.

-- ===============================
-- Pattern 2 — Debug an error
-- Example of a common error with dates:
-- Wrong query that gives an error:
-- SELECT * FROM orders WHERE order_date > 2025-01-01;
-- Error: operator does not exist: date = integer

-- Explanation:
-- PostgreSQL interprets 2025-01-01 without quotes as arithmetic: 2025 minus 1 minus 1 = 2023, which is an integer.
-- Comparing date = integer causes the error.

-- Corrected query:
SELECT * FROM orders
WHERE order_date > '2025-01-01';

-- Rule:
-- Always wrap date values in single quotes in SQL. Double quotes are for column/table identifiers.

-- Other common date mistakes:
-- - Comparing a date column with a string that is not in correct format.
-- - Using functions without casting (e.g., extracting month as text and comparing directly with integer).

-- ===============================
-- Pattern 3 — Extend a query you already wrote
-- Original query:
SELECT product_name, category, price
FROM products
WHERE price > 2000
ORDER BY price DESC
LIMIT 10;

-- 1. Add a column showing stock value (price × stock_qty):
-- Concept: Multiply the price of each product by its stock quantity to get total stock value for that product.
SELECT product_name,
       category,
       price,
       stock_qty,
       ROUND(price * stock_qty, 2) AS stock_value
FROM products
WHERE price > 2000
ORDER BY price DESC
LIMIT 10;

-- 2. Filter only products with stock below 20:
SELECT product_name,
       category,
       price,
       stock_qty,
       ROUND(price * stock_qty, 2) AS stock_value
FROM products
WHERE price > 2000
  AND stock_qty < 20
ORDER BY price DESC
LIMIT 10;

-- 3. Challenge variation for practice:
-- Find top 5 products by stock value, show category, and mark 'High Value' if stock_value > 50000 else 'Regular'.
SELECT product_name,
       category,
       price,
       stock_qty,
       ROUND(price * stock_qty, 2) AS stock_value,
       CASE
           WHEN price * stock_qty > 50000 THEN 'High Value'
           ELSE 'Regular'
       END AS value_label
FROM products
ORDER BY stock_value DESC
LIMIT 5;
