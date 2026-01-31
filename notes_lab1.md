# Database Lab 1 – PostgreSQL (Enhanced Notes)

## Introduction
This lab focuses on understanding the fundamentals of relational databases using PostgreSQL.
It covers table creation, data insertion, querying data, database backup, and version control
using GitHub. The lab provides hands-on experience with real database operations.

---

## What is PostgreSQL?
PostgreSQL is a powerful, open-source Relational Database Management System (RDBMS).
It supports:
- Structured Query Language (SQL)
- Data integrity and constraints
- Transactions and concurrency control
- Backup and recovery mechanisms

PostgreSQL is widely used in industry, research, and academic environments.

---

## What is a Database?
A database is an organized collection of related data stored electronically.
It allows users to:
- Store large amounts of data efficiently
- Retrieve data quickly using queries
- Maintain accuracy and consistency of data

---

## What is a Table?
A table is a basic structure in a relational database.
It consists of:
- Rows (records)
- Columns (attributes)

Each row represents one entity, and each column represents a property of that entity.

---

## Table Created in This Lab
The `books_read` table stores information about books, including:
- Book title
- Author name
- Category
- Number of pages
- Date finished
- Rating
- Notes

This table demonstrates real-world data modeling.

---

## SQL Commands Used

### CREATE TABLE
Used to create a new table in the database.
Constraints were added to maintain data accuracy and integrity.

Example:
- PRIMARY KEY ensures uniqueness
- NOT NULL prevents missing values
- CHECK enforces valid ranges

---

### INSERT
Used to add records into the table.
Multiple rows were inserted using a single SQL command.

---

### SELECT
Used to retrieve data from the table.
It helps verify that data has been inserted correctly.

---

### PostgreSQL Meta Commands
- `\dt` → Displays all tables in the database
- `\d table_name` → Displays table structure and constraints

---

## Constraints Used and Their Importance

- **PRIMARY KEY**
  Ensures each record is unique and identifiable.

- **NOT NULL**
  Prevents storing empty values in important columns.

- **CHECK**
  Validates data before insertion (e.g., pages > 0, rating between 0 and 5).

Constraints help maintain **data integrity** and **data quality**.

---

## Database Backup
A database backup was created using `pg_dump`.
Backup files are important because they:
- Protect against data loss
- Allow database restoration
- Support migration and recovery

The backup file used in this lab:
- `lab1_db_backup.dump`

---

## Git and GitHub Usage
Git and GitHub were used for version control.
They help in:
- Tracking changes in SQL files
- Managing lab work efficiently
- Submitting assignments online
- Maintaining project history

All lab files were pushed to a GitHub repository.

---

## Files Included in the Repository
- `books_read_table.sql` – Table creation script
- `queries.sql` – SQL queries for lab exercises
- `lab1_db_backup.dump` – Database backup
- `notes_lab1.md` – Theory and explanation notes
- `README.md` – Lab overview

---

## Learning Outcomes
After completing this lab, the following concepts were learned:
- Basics of PostgreSQL and relational databases
- Creating tables with constraints
- Inserting and retrieving data using SQL
- Importance of database backups
- Using Git and GitHub for version control

---

## Conclusion
This lab provided a strong foundation in database management using PostgreSQL.
It combined theoretical knowledge with practical implementation, making it
useful for future database-related tasks and projects.
