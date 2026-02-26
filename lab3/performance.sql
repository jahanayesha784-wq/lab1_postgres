-- Lab 3: Performance Awareness
-- Instructor: Muhammad Usama Afridi

---------------------------------------------------
-- Query 3: Monthly Revenue
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- EXPLAIN ANALYZE Output:
-- GroupAggregate  (cost=2.19..3.01 rows=30 width=72) (actual time=1.485..1.535 rows=12 loops=1)
--   Group Key: (to_char((order_date)::timestamp with time zone, 'YYYY-MM'::text))
--   ->  Sort  (cost=2.19..2.26 rows=30 width=48) (actual time=1.458..1.465 rows=30 loops=1)
--         Sort Key: (to_char((order_date)::timestamp with time zone, 'YYYY-MM'::text))
--         Sort Method: quicksort  Memory: 25kB
--         ->  Seq Scan on orders  (cost=0.00..1.45 rows=30 width=48) (actual time=1.233..1.298 rows=30 loops=1)
-- Planning Time: 7.997 ms
-- Execution Time: 3.878 ms

-- Explanation:
-- This query uses a simple GROUP BY with aggregation.
-- Execution is fast because PostgreSQL uses a GroupAggregate on a sequential scan
-- and sorts only 12 rows in memory. Very few operations.

---------------------------------------------------
-- Query 9: Customer Segmentation Using CTEs
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
       ROUND(SUM(total_spent), 2) AS tier_revenue,
       ROUND(
           100.0 * SUM(total_spent) /
           NULLIF(SUM(SUM(total_spent)) OVER (), 0),
           1
       ) AS revenue_share_pct
FROM customer_tiers
GROUP BY tier
ORDER BY tier_revenue DESC;

-- EXPLAIN ANALYZE Output:
-- Sort  (cost=25.59..25.84 rows=100 width=104) (actual time=0.327..0.333 rows=4 loops=1)
--   Sort Key: (round((sum(customer_spend.total_spent)), 2)) DESC
--   Sort Method: quicksort  Memory: 25kB
--   ->  WindowAgg  (cost=20.24..22.27 rows=100 width=104) (actual time=0.273..0.289 rows=4 loops=1)
--         ->  HashAggregate  (cost=17.02..19.02 rows=100 width=72) (actual time=0.230..0.240 rows=4 loops=1)
--               Group Key: CASE WHEN (customer_spend.total_spent > 30000) THEN 'VIP'::text WHEN (customer_spend.total_spent > 10000) THEN 'High Value'::text WHEN (customer_spend.total_spent > 0) THEN 'Active'::text ELSE 'Never Purchased'::text END
--               ->  Subquery Scan on customer_spend  (cost=13.27..16.27 rows=100 width=64) (actual time=0.168..0.205 rows=20 loops=1)
--                     ->  HashAggregate  (cost=13.27..14.52 rows=100 width=36) (actual time=0.163..0.187 rows=20 loops=1)
--                           ->  Hash Left Join  (cost=1.39..12.77 rows=100 width=20) (actual time=0.088..0.112 rows=25 loops=1)
--                                 Hash Cond: (c.customer_id = o.customer_id)
--                                 ->  Seq Scan on customers c  (cost=0.00..11.00 rows=100 width=4) (actual time=0.026..0.031 rows=20 loops=1)
--                                 ->  Hash  (cost=1.38..1.38 rows=1 width=20) (actual time=0.048..0.049 rows=20 loops=1)
--                                       ->  Seq Scan on orders o  (cost=0.00..1.38 rows=1 width=20) (actual time=0.016..0.033 rows=20 loops=1)
--                                             Filter: ((status)::text = 'delivered'::text)
-- Planning Time: 0.779 ms
-- Execution Time: 0.521 ms

-- Explanation:
-- This query is more complex. It involves:
-- 1. A LEFT JOIN to include all customers.
-- 2. Two CTEs: customer_spend and customer_tiers.
-- 3. Aggregation and a window function to calculate revenue share.
-- More operations are performed than in Query 3, but the dataset is small, so execution is still fast.
