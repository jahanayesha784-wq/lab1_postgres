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
-- 1. Select all columns from books_read
SELECT * FROM books_read;

-- 2. Select only title and author
SELECT title, author FROM books_read;

-- 3. Select books with rating above 4.5
SELECT * FROM books_read
WHERE rating > 4.5;

-- 4. Select books finished after October 1, 2024
SELECT * FROM books_read
WHERE date_finished > '2024-10-01';
-- 5. Count total books read
SELECT COUNT(*) AS total_books FROM books_read;

-- 6. Average rating of all books
SELECT AVG(rating) AS avg_rating FROM books_read;

-- 7. Maximum and minimum pages
SELECT MAX(pages) AS max_pages, MIN(pages) AS min_pages FROM books_read;

-- 8. Count books per category
SELECT category, COUNT(*) AS count
FROM books_read
GROUP BY category;
-- 9. List books ordered by rating descending
SELECT * FROM books_read
ORDER BY rating DESC;

-- 10. Top 3 highest rated books
SELECT * FROM books_read
ORDER BY rating DESC
LIMIT 3;

-- 11. List books by pages in ascending order
SELECT * FROM books_read
ORDER BY pages ASC;
-- 12. Update rating for a specific book
UPDATE books_read
SET rating = 4.7
WHERE title = 'Clean Code';

-- 13. Add a note to a specific book
UPDATE books_read
SET notes = 'Excellent coding style'
WHERE title = 'Clean Code';
-- 14. Delete a book by title
DELETE FROM books_read
WHERE title = 'The Hundred-Page Machine Learning Book';

-- 15. Delete all books in a category
DELETE FROM books_read
WHERE category = 'Databases';
-- 16. Books with rating between 4 and 5
SELECT * FROM books_read
WHERE rating BETWEEN 4 AND 5;

-- 17. Count books finished each month
SELECT EXTRACT(MONTH FROM date_finished) AS month, COUNT(*) AS count
FROM books_read
GROUP BY month
ORDER BY month;

-- 18. Find books by author
SELECT * FROM books_read
WHERE author ILIKE '%Martin%';  -- case-insensitive search
