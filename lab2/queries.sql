-- Part 3 — Lab Exercises
-- Save this as lab2/queries.sql

-- Query 1 — Explore the data
SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;

-- Query 2 — Select specific columns
SELECT name, city, signup_date
FROM customers
ORDER BY signup_date;

-- Query 2b — Descending order
SELECT name, city, signup_date
FROM customers
ORDER BY signup_date DESC;

-- Query 3 — Filter by status
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC;

-- Query 3b — pending orders
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'pending';

-- Query 3c — cancelled orders
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'cancelled';

-- Query 4 — Filter by price range
-- Method A: BETWEEN
SELECT product_name, category, price
FROM products
WHERE price BETWEEN 1000 AND 5000
ORDER BY price;

-- Method B: Comparison operators
SELECT product_name, category, price
FROM products
WHERE price >= 1000 AND price <= 5000
ORDER BY price;

-- Query 5 — Top 10 highest-value orders
SELECT order_id, customer_id, total_amount, status
FROM orders
ORDER BY total_amount DESC
LIMIT 10;

-- Query 6 — Multi-condition filter
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'delivered'
  AND order_date >= '2025-01-01'
  AND total_amount > 10000
ORDER BY total_amount DESC;

-- Query 7 — Pattern matching on email
-- Gmail users
SELECT name, email, city
FROM customers
WHERE email LIKE '%@gmail.com'
ORDER BY name;

-- Case-insensitive version
SELECT name, email, city
FROM customers
WHERE email ILIKE '%@gmail.com'
ORDER BY name;

-- Yahoo users
SELECT name, email, city
FROM customers
WHERE email LIKE '%yahoo%';

-- Names starting with 'a'
SELECT name, email, city
FROM customers
WHERE name LIKE 'a%';

-- Query 8 — NULL handling (unshipped orders)
SELECT order_id, customer_id, order_date, status, total_amount
FROM orders
WHERE shipped_date IS NULL
ORDER BY order_date;

-- Wrong approach (for demonstration)
SELECT * FROM orders WHERE shipped_date = NULL;

-- Query 9 — Computed column: discounted price
SELECT product_name,
       category,
       price AS original_price,
       ROUND(price * 0.80, 2) AS discounted_price,
       ROUND(price * 0.20, 2) AS you_save
FROM products
ORDER BY discounted_price DESC;

-- Query 10 — Top 5 highest-value unshipped orders with priority
SELECT order_id,
       customer_id,
       total_amount,
       order_date,
       status,
       CASE
           WHEN total_amount > 20000 THEN 'CRITICAL'
           WHEN total_amount > 5000 THEN 'URGENT'
           ELSE 'NORMAL'
       END AS priority
FROM orders
WHERE shipped_date IS NULL
  AND order_date >= '2025-01-01'
ORDER BY total_amount DESC
LIMIT 5;
