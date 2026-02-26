-- ###########################################################
-- Lab 3: Performance Analysis + AI Prompting Exercises
-- ###########################################################

-- #######################
-- Part 4: Performance Awareness (EXPLAIN ANALYZE)
-- #######################

-- Query 3: Monthly order volume and revenue
EXPLAIN ANALYZE
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- Explanation of the output:
-- 1. GroupAggregate: PostgreSQL performs GROUP BY using a hash aggregation. Groups rows and calculates aggregates.
-- 2. Sort: ORDER BY triggers sorting. Memory usage shows whether it sorted in-memory or used disk.
-- 3. Seq Scan: Reads all rows in the 'orders' table sequentially.
-- 4. Planning vs Execution: Estimated rows vs actual rows shows how accurate the planner's estimate was.
-- 5. Execution time: The actual time to run the query (3.878 ms here).

-- Query 9: Customer segmentation CTE
EXPLAIN ANALYZE
WITH customer_spend AS (
    SELECT c.customer_id,
           COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o
           ON c.customer_id = o.customer_id
           AND o.status = 'delivered'
    GROUP BY c.customer_id
),
customer_tiers AS (
    SELECT *,
           CASE
               WHEN total_spent > 30000 THEN 'VIP'
               WHEN total_spent > 10000 THEN 'High Value'
               WHEN total_spent > 0 THEN 'Active'
               ELSE 'Never Purchased'
           END AS tier
    FROM customer_spend
)
SELECT tier,
       COUNT(*) AS num_customers,
       SUM(total_spent) AS total_revenue
FROM customer_tiers
GROUP BY tier
ORDER BY total_revenue DESC;

-- Explanation:
-- 1. CTEs create named temporary result sets. First computes total spend per customer, second assigns tiers.
-- 2. HashAggregate and WindowAgg: PostgreSQL performs aggregation and ranking.
-- 3. Multiple operations: This query involves more steps than the simple monthly revenue query.
-- 4. Execution time: Even though the dataset is small, CTEs add planning steps.

-- Observations:
-- - Query 9 (CTEs) has more operations because it combines multiple temporary tables and calculations.
-- - Query 3 is simpler: just group and sum.
-- - CTE queries are easier to read and debug but may slightly increase planning overhead.


-- #######################
-- Part 5: AI Prompting for Window Functions & CTEs (with example outputs and explanations)
-- #######################

-- Pattern 1 — Understanding PARTITION BY

-- Query with PARTITION BY
SELECT customer_id,
       order_id,
       total_amount,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY total_amount DESC
       ) AS rank_within_customer
FROM orders
ORDER BY customer_id, rank_within_customer;

-- Example Output:
-- customer_id | order_id | total_amount | rank_within_customer
-- ------------+----------+--------------+--------------------
-- 1           | 105      | 5000         | 1
-- 1           | 102      | 3000         | 2
-- 1           | 110      | 1000         | 3
-- 2           | 201      | 4500         | 1
-- 2           | 203      | 2000         | 2
-- 2           | 205      | 1500         | 3

-- Explanation:
-- PARTITION BY creates separate "groups" for each customer_id.
-- ROW_NUMBER() resets numbering within each group.
-- Analogy: Each customer is like a classroom. ROW_NUMBER assigns seats starting from 1 in each classroom.

-- Query without PARTITION BY (global ranking)
SELECT customer_id,
       order_id,
       total_amount,
       ROW_NUMBER() OVER (
           ORDER BY total_amount DESC
       ) AS rank_global
FROM orders;

-- Example Output:
-- customer_id | order_id | total_amount | rank_global
-- ------------+----------+--------------+------------
-- 1           | 105      | 5000         | 1
-- 2           | 201      | 4500         | 2
-- 1           | 102      | 3000         | 3
-- 2           | 203      | 2000         | 4
-- 1           | 110      | 1000         | 5
-- 2           | 205      | 1500         | 6

-- Explanation:
-- Without PARTITION BY, ROW_NUMBER() is calculated across the entire dataset.
-- Ranking is global, not per customer.

-- ROW_NUMBER vs RANK vs DENSE_RANK
SELECT customer_id,
       order_id,
       total_amount,
       ROW_NUMBER() OVER (ORDER BY total_amount DESC) AS rn,
       RANK() OVER (ORDER BY total_amount DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY total_amount DESC) AS drnk
FROM orders
ORDER BY total_amount DESC;

-- Example Output (demonstrating differences when amounts tie):
-- customer_id | order_id | total_amount | rn | rnk | drnk
-- ------------+----------+--------------+----+-----+-----
-- 1           | 105      | 5000         | 1  | 1   | 1
-- 2           | 201      | 4500         | 2  | 2   | 2
-- 3           | 301      | 4500         | 3  | 2   | 2
-- 4           | 402      | 3000         | 4  | 4   | 3

-- Explanation:
-- ROW_NUMBER: always unique, ignores ties (1,2,3,4)
-- RANK: ties share same rank, next rank skips numbers (1,2,2,4)
-- DENSE_RANK: ties share rank, no skipping (1,2,2,3)

-- #######################
-- Pattern 2 — Debugging a GROUP BY error

-- Incorrect Query:
-- SELECT category, product_name, COUNT(*), AVG(price)
-- FROM products
-- GROUP BY category;
-- Error occurs because product_name is not aggregated and not in GROUP BY

-- Correct Version 1: include product_name
SELECT category,
       product_name,
       COUNT(*) AS product_count,
       AVG(price) AS avg_price
FROM products
GROUP BY category, product_name;

-- Example Output:
-- category | product_name | product_count | avg_price
-- ---------+--------------+---------------+----------
-- Electronics | Laptop    | 2             | 750
-- Electronics | Phone     | 3             | 400
-- Furniture   | Chair     | 5             | 50
-- Furniture   | Desk      | 2             | 150

-- Correct Version 2: remove product_name
SELECT category,
       COUNT(*) AS product_count,
       AVG(price) AS avg_price
FROM products
GROUP BY category;

-- Example Output:
-- category    | product_count | avg_price
-- ----------- +---------------+----------
-- Electronics | 5             | 550
-- Furniture   | 7             | 85

-- Explanation:
-- Rule: Columns in SELECT must either be aggregated (SUM, AVG, COUNT...) or listed in GROUP BY.
-- Non-aggregated, non-GROUP BY columns cause an error.

-- #######################
-- Pattern 3 — Building a CTE step by step

WITH customer_spend AS (
    -- Step 1: Calculate total spend per customer
    SELECT c.customer_id,
           c.name,
           COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o
           ON c.customer_id = o.customer_id
           AND o.status = 'delivered'
    GROUP BY c.customer_id, c.name
),
top_customers AS (
    -- Step 2: Pick top 3 spenders
    SELECT *
    FROM customer_spend
    ORDER BY total_spent DESC
    LIMIT 3
),
customer_orders AS (
    -- Step 3: Most recent order and avg order value
    SELECT o.customer_id,
           MAX(order_date) AS recent_order_date,
           ROUND(AVG(total_amount), 2) AS avg_order_value
    FROM orders o
    WHERE o.customer_id IN (SELECT customer_id FROM top_customers)
      AND o.status = 'delivered'
    GROUP BY o.customer_id
)
SELECT t.customer_id,
       t.name,
       t.total_spent,
       co.recent_order_date,
       co.avg_order_value
FROM top_customers t
JOIN customer_orders co
     ON t.customer_id = co.customer_id
ORDER BY t.total_spent DESC;

-- Example Output:
-- customer_id | name      | total_spent | recent_order_date | avg_order_value
-- ------------+-----------+------------+------------------+----------------
-- 6           | Alice     | 79500       | 2025-08-12       | 26500.00
-- 17          | Bob       | 28000       | 2025-09-03       | 14000.00
-- 13          | Charlie   | 21700       | 2025-07-29       | 10850.00

-- Explanation:
-- Step 1: CTE computes total spend for each customer
-- Step 2: Another CTE picks the top 3 customers
-- Step 3: Another CTE calculates most recent order and avg order value
-- Step 4: Join top_customers with customer_orders to get final output
-- CTEs keep queries readable, testable, and modular.

-- Challenge: Top 5 cities by total revenue, then top 2 customers per city.
