-- View all records
SELECT * FROM books_read;

-- Select specific columns
SELECT title, author, rating FROM books_read;

-- WHERE condition
SELECT title, rating
FROM books_read
WHERE rating >= 4.5;

-- ORDER BY pages descending
SELECT title, pages
FROM books_read
ORDER BY pages DESC;

-- COUNT books
SELECT COUNT(*) AS total_books FROM books_read;

-- GROUP BY category
SELECT category, COUNT(*) 
FROM books_read
GROUP BY category;

-- UPDATE example
UPDATE books_read
SET rating = 4.7
WHERE title = 'Clean Code';

-- Verify update
SELECT title, rating FROM books_read WHERE title='Clean Code';

-- DELETE example (optional)
DELETE FROM books_read
WHERE pages < 200;
