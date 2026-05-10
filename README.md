# 🛒 Amazon Retail SQL Project

A comprehensive SQL analysis of an Amazon retail dataset demonstrating **industry-level SQL skills** across 52 queries — from basic filtering to advanced analytics, window functions, CTEs, and stored procedures.

---

## 📁 Repository Structure

```
Retail-SQL-Project/
│
├── SQL_queries/
│   └── Amazon_Retail_SQL_Project.sql   ← All 52 queries
│
├── amazon_sales_1000.csv               ← Source dataset
└── README.md
```

---

## 🗄️ Dataset Schema

| Column | Type | Description |
|---|---|---|
| `order_id` | VARCHAR (PK) | Unique order identifier |
| `order_date` | DATE | Date the order was placed |
| `product` | VARCHAR | Product name |
| `category` | VARCHAR | Product category (Electronics, Fashion, etc.) |
| `price` | DECIMAL | Unit price |
| `quantity` | INT | Units ordered |
| `total_sales` | DECIMAL | price × quantity |
| `city` | VARCHAR | Delivery city |
| `payment_method` | VARCHAR | Payment type (Credit Card, UPI, COD, etc.) |

---

## 🎯 Project Objectives

- Perform end-to-end retail sales analysis using SQL alone
- Demonstrate proficiency across all SQL complexity levels
- Answer real business questions with actionable insights
- Showcase multi-table design, views, and stored procedures

---

## 📊 SQL Techniques Demonstrated

| # | Section | Key Concepts |
|---|---|---|
| 0 | Schema Design & DDL | `CREATE TABLE`, constraints, generated columns, foreign keys |
| 1 | Data Cleaning | NULL checks, duplicate detection, `UPDATE`, outlier detection |
| 2 | Basic Queries | `WHERE`, `LIKE`, `ORDER BY`, `LIMIT`, date functions |
| 3 | Aggregation | `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| 4 | Subqueries | Correlated subqueries, `IN`, `NOT IN`, scalar subqueries |
| 5 | CTEs | `WITH` clauses, chained CTEs, recursive-style logic |
| 6 | Window Functions | `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, `NTILE`, `PERCENT_RANK`, `FIRST_VALUE` |
| 7 | Joins | `INNER JOIN`, `LEFT JOIN`, `SELF JOIN`, multi-table design |
| 8 | Advanced Analytics | ABC analysis, Pareto 80/20, Pivot tables, Z-score anomaly detection, Market basket, KPI dashboard |
| 9 | Programmability | Stored Procedure, View |

---

## 🔍 Key Business Questions Answered

1. What is the total revenue, average order value, and order count?
2. Which categories drive the most revenue? (% contribution)
3. What is the month-over-month revenue growth trend?
4. Which cities generate the highest sales?
5. What payment methods do customers prefer?
6. Which products are top-sellers within each category?
7. What is the running total of revenue over time?
8. Which orders are high-value outliers (>2x average)?
9. Which products contribute to 80% of revenue? (Pareto)
10. How do we classify products by value? (ABC Analysis)
11. Which days of the week generate the most revenue?
12. Are there any anomalous revenue days? (Z-score analysis)
13. What products are frequently bought together? (Market basket proxy)
14. What does the executive KPI dashboard look like?

---

## 💡 Key Findings

> *(Update these with your actual query results)*

- **Total Revenue**: ₹X,XX,XXX from 1,000 orders
- **Top Category**: Electronics drives ~XX% of total revenue
- **Best Month**: [Month YYYY] peaked at ₹XX,XXX
- **Top City**: [City] leads with ₹XX,XXX in sales
- **Payment Preference**: XX% of orders use Credit Card
- **High-Value Products**: Top 20% of products generate 80% of revenue (Pareto confirmed)

---

## 🛠️ How to Run

1. Import the CSV into your SQL database:
   ```sql
   LOAD DATA INFILE 'amazon_sales_1000.csv'
   INTO TABLE amazon_sales
   FIELDS TERMINATED BY ','
   ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;
   ```

2. Open `Amazon_Retail_SQL_Project.sql` and run sections in order (0 → 8)

3. Compatible with: **MySQL 8+**, **PostgreSQL 13+**, **SQLite** (minor syntax adjustments for date functions)

---

## 🧠 SQL Concepts Quick Reference

```sql
-- Window Function example (Q30)
RANK() OVER (PARTITION BY category ORDER BY SUM(total_sales) DESC)

-- CTE example (Q25)
WITH monthly AS (SELECT ...), growth AS (SELECT ... FROM monthly)
SELECT * FROM growth;

-- ABC Analysis (Q41)
CASE WHEN cum_pct <= 70 THEN 'A' WHEN cum_pct <= 90 THEN 'B' ELSE 'C' END

-- Pivot with CASE WHEN (Q44)
SUM(CASE WHEN category = 'Electronics' THEN total_sales ELSE 0 END)
```

---

## 👩‍💻 Author

**Dipali** | Aspiring Data Scientist  
📍 India | 🔗 [GitHub](https://github.com/Dipali-cpu)

---

*This project is part of my data analytics portfolio demonstrating end-to-end SQL skills for real-world business analysis.*
