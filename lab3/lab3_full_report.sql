-- Lab 3 Full Report
-- Author: Aisha Noor
-- Roll Number: 03
-- Data Science
-- semester: 4rth
-- Subject: Database System
-- Date: 26-Feb-2026
-- Description: Aggregation, Window Functions, CTEs, Performance Analysis, AI Prompting, and Reflection

-- ===================================================================
-- Section 1: 10 Queries with Explanation & Business Insights
-- ===================================================================

-- Query 1: Overall business summary
SELECT COUNT(*) AS total_orders,
       SUM(total_amount) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value,
       MAX(total_amount) AS largest_order
FROM orders
WHERE status = 'delivered';
-- Explanation:
-- This KPI summary shows the total delivered orders, total revenue, average order value, and the largest single order.
-- Insight: Helps identify overall sales health. Large orders indicate potential VIP customers. Average order value helps pricing strategies.

-- Query 2: Revenue by product category
SELECT p.category,
       COUNT(DISTINCT oi.order_id) AS orders_containing,
       SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;
-- Explanation:
-- Electronics generates more revenue than Books even if fewer products exist, suggesting Electronics are the primary revenue driver.
-- Insight: Marketing campaigns should focus on high-revenue categories to maximize ROI.

-- Query 3: Monthly order volume and revenue
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;
-- Explanation:
-- August 2025 shows the highest revenue and order volume, likely due to seasonal promotions.
-- Insight: Sales trends can guide inventory planning and marketing timing.

-- Query 4: Active cities with more than 2 orders
SELECT c.city,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING COUNT(o.order_id) > 2
ORDER BY total_orders DESC;
-- Explanation:
-- Highlights cities with concentrated demand. Larger order counts indicate stronger customer engagement.
-- Insight: Focus customer support, marketing, and inventory on high-performing cities.

-- Query 5: Device performance with HAVING
SELECT device,
       COUNT(*) AS total_sessions,
       ROUND(AVG(duration_mins), 2) AS avg_duration,
       SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS conversions,
       ROUND(
           100.0 * SUM(CASE WHEN converted THEN 1 ELSE 0 END) / COUNT(*),
           1
       ) AS conversion_rate_pct
FROM user_sessions
GROUP BY device
HAVING COUNT(*) >= 5
AND AVG(duration_mins) > 15
ORDER BY conversion_rate_pct DESC;
-- Explanation:
-- Devices with longer sessions and higher conversion rates indicate better UX and engagement.
-- Insight: Optimize site/app for high-performing devices and investigate low-performing ones.

-- Query 6: Rank orders per customer
SELECT customer_id,
       order_id,
       order_date,
       total_amount,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_within_customer
FROM orders
ORDER BY customer_id, rank_within_customer;
-- Explanation:
-- ROW_NUMBER() ranks orders within each customer to identify top-value orders.
-- Insight: Useful for targeting top-spending customers for loyalty programs.

-- Query 7: Overall revenue ranking with RANK and DENSE_RANK
SELECT order_id,
       customer_id,
       total_amount,
       RANK() OVER (ORDER BY total_amount DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY total_amount DESC) AS dense_rank
FROM orders
ORDER BY total_amount DESC
LIMIT 15;
-- Explanation:
-- Compares how RANK and DENSE_RANK handle ties.
-- Insight: DENSE_RANK is often more intuitive in reports; RANK may skip numbers in case of ties.

-- Query 8: Month-over-month revenue trend with LAG
WITH monthly_revenue AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,
       revenue - LAG(revenue) OVER (ORDER BY month) AS absolute_change,
       ROUND(
           100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
           1
       ) AS pct_change
FROM monthly_revenue
ORDER BY month;
-- Explanation:
-- Shows month-to-month revenue growth or decline.
-- Insight: Identifies revenue spikes and slow months to adjust marketing or promotions.

-- Query 9: Customer segmentation using CTEs
WITH customer_spend AS (
    SELECT c.customer_id,
           c.name,
           c.city,
           COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o
           ON c.customer_id = o.customer_id
           AND o.status = 'delivered'
    GROUP BY c.customer_id, c.name, c.city
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
           100.0 * SUM(total_spent) / NULLIF(SUM(SUM(total_spent)) OVER (), 0),
           1
       ) AS revenue_share_pct
FROM customer_tiers
GROUP BY tier
ORDER BY tier_revenue DESC;
-- Explanation:
-- Categorizes customers by spending tiers.
-- Insight: Marketing can target high-value and VIP customers for retention campaigns.

-- Query 10: Session-to-purchase funnel analysis
WITH session_summary AS (
    SELECT customer_id,
           COUNT(*) AS total_sessions,
           SUM(pages_viewed) AS total_pages,
           ROUND(AVG(duration_mins), 2) AS avg_duration,
           SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS converted_sessions
    FROM user_sessions
    GROUP BY customer_id
),
order_summary AS (
    SELECT customer_id,
           COUNT(*) AS total_orders,
           SUM(total_amount) AS total_spent
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
),
combined AS (
    SELECT c.name,
           c.city,
           s.total_sessions,
           s.total_pages,
           s.avg_duration,
           s.converted_sessions,
           COALESCE(o.total_orders, 0) AS total_orders,
           COALESCE(o.total_spent, 0) AS total_spent
    FROM session_summary s
    JOIN customers c ON s.customer_id = c.customer_id
    LEFT JOIN order_summary o ON s.customer_id = o.customer_id
)
SELECT name,
       city,
       total_sessions,
       total_pages,
       avg_duration,
       total_orders,
       total_spent,
       ROUND(
           CASE WHEN total_sessions > 0
                THEN 100.0 * total_orders / total_sessions
                ELSE 0
           END, 1
       ) AS orders_per_100_sessions
FROM combined
ORDER BY total_sessions DESC, orders_per_100_sessions ASC;
-- Explanation:
-- Highlights customers with high browsing but low purchases.
-- Insight: Identifies churn risk and re-engagement opportunities.

-- ===================================================================
-- Section 2: Performance Report with EXPLAIN ANALYZE
-- ===================================================================

-- Query 3 EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;
-- Observation:
-- Uses GroupAggregate, Seq Scan, Sort.
-- Fewer operations, fast (~3.8 ms).

-- Query 9 EXPLAIN ANALYZE
WITH customer_spend AS (
    SELECT c.customer_id,
           c.name,
           c.city,
           COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o
           ON c.customer_id = o.customer_id
           AND o.status = 'delivered'
    GROUP BY c.customer_id, c.name, c.city
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
           100.0 * SUM(total_spent) / NULLIF(SUM(SUM(total_spent)) OVER (), 0),
           1
       ) AS revenue_share_pct
FROM customer_tiers
GROUP BY tier
ORDER BY tier_revenue DESC;
-- Observation:
-- More operations due to joins, CTEs, and window functions.
-- Slightly slower but allows detailed customer segmentation.

-- ===================================================================
-- Section 3: AI Prompting Exercises (Part 5)
-- ===================================================================

-- Pattern 1: PARTITION BY in ROW_NUMBER
-- Analogy: Imagine each customer has their own row of orders; numbering restarts for each customer.
-- Example Output for 2 customers with 3 orders each:
-- customer_id | order_id | total_amount | rank_within_customer
-- 1           | 101      | 500          | 1
-- 1           | 102      | 300          | 2
-- 1           | 103      | 200          | 3
-- 2           | 201      | 450          | 1
-- 2           | 202      | 350          | 2
-- 2           | 203      | 150          | 3
-- Without PARTITION BY, ROW_NUMBER numbers all orders sequentially across all customers.
-- Difference between ROW_NUMBER, RANK, DENSE_RANK:
-- Example: Orders with amounts 500, 500, 400
-- ROW_NUMBER -> 1,2,3
-- RANK -> 1,1,3
-- DENSE_RANK -> 1,1,2

-- Pattern 2: GROUP BY error debugging
-- Error: SELECTing product_name without including in GROUP BY or aggregate.
-- Correct versions:
-- 1) Include product_name: GROUP BY category, product_name
-- 2) Remove product_name: SELECT category, COUNT(*), AVG(price) GROUP BY category
-- Rule: Every non-aggregated column in SELECT must appear in GROUP BY.

-- Pattern 3: CTE for top 3 customers
-- Step 1: Compute total spend per customer
-- Step 2: Rank customers by total spend
-- Step 3: For top 3 customers, compute most recent order and average order
WITH total_spend AS (
    SELECT customer_id,
           SUM(total_amount) AS spend
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT customer_id,
           spend,
           RANK() OVER (ORDER BY spend DESC) AS rank
    FROM total_spend
)
SELECT rc.customer_id,
       MAX(o.order_date) AS most_recent_order,
       AVG(o.total_amount) AS avg_order_value
FROM ranked_customers rc
JOIN orders o ON rc.customer_id = o.customer_id
WHERE rc.rank <= 3
GROUP BY rc.customer_id;
-- Explanation: Breaks complex query into readable steps. Each CTE produces meaningful intermediate results.

-- ===================================================================
-- Section 4: Reflection
-- ===================================================================
-- WHERE filters individual rows before aggregation; HAVING filters groups after aggregation.
-- Window functions are used when you want per-row calculations without collapsing rows.
-- PARTITION BY initially confusing, but visualizing per-customer order ranking clarified its use.
-- CTEs improved readability for multi-step queries and allowed testing intermediate results.
-- The most challenging part was combining window functions with CTEs. Once visualized step-by-step, it clicked.
