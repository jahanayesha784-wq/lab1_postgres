-- AGREGATION
-- Total orders, revenue, average order value
SELECT COUNT(*) AS total_orders,
       SUM(total_amount) AS total_revenue,
       AVG(total_amount) AS avg_order_value,
       MIN(total_amount) AS smallest_order,
       MAX(total_amount) AS largest_order
FROM orders
WHERE status = 'delivered';

--GROUP BY
-- Revenue by order status
SELECT status,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- Average session duration by device
SELECT device,
       COUNT(*) AS sessions,
       ROUND(AVG(duration_mins), 2) AS avg_duration_mins
FROM user_sessions
GROUP BY device
ORDER BY avg_duration_mins DESC;

--HAVING
-- Orders in 2025 with more than 3 orders per status
SELECT status,
       COUNT(*) AS num_orders,
       SUM(total_amount) AS total_revenue
FROM orders
WHERE order_date >= '2025-01-01'
GROUP BY status
HAVING COUNT(*) > 3
ORDER BY total_revenue DESC;

-- Product categories with avg price > 3000
SELECT category,
       COUNT(*) AS products,
       ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 3000
ORDER BY avg_price DESC;

--WINDOW FUNCTION
-- ROW_NUMBER per customer
SELECT customer_id,
       order_date,
       total_amount,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS order_rank_by_customer
FROM orders;

-- RANK overall orders
SELECT customer_id,
       total_amount,
       RANK() OVER (ORDER BY total_amount DESC) AS overall_rank
FROM orders;

-- Month-over-month revenue using LAG
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       SUM(total_amount) AS revenue,
       LAG(SUM(total_amount)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')) AS prev_month_revenue
FROM orders
WHERE status = 'delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

--CTE EXAMPLE
WITH customer_totals AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
)
SELECT customer_id, total_spent
FROM customer_totals
WHERE total_spent > 10000
ORDER BY total_spent DESC;

-- Multi-step CTE with tiers
WITH customer_spend AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent,
           COUNT(*) AS num_orders
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
),
customer_tiers AS (
    SELECT customer_id,
           total_spent,
           num_orders,
           CASE
               WHEN total_spent > 30000 THEN 'VIP'
               WHEN total_spent > 10000 THEN 'Regular'
               ELSE 'Occasional'
           END AS tier
    FROM customer_spend
)
SELECT tier,
       COUNT(*) AS num_customers,
       SUM(total_spent) AS total_revenue
FROM customer_tiers
GROUP BY tier
ORDER BY total_revenue DESC;
