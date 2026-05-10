# 🛒 Ecommerce SQL Project — Industry Level Analysis

A comprehensive SQL project analyzing a **normalized 5-table ecommerce database** using **52 industry-level queries** — covering everything from basic filtering to advanced analytics, window functions, CTEs, stored procedures, and views.

---

## 👩‍💻 Author
**Dipali** | Aspiring Data Scientist
📍 India | 🔗 [GitHub](https://github.com/Dipali-cpu)

---

## 📁 Repository Structure

```
Retail-SQL-Project/
│
├── SQL_queries/
│   └── Ecommerce_SQL_Project_52_Queries.sql   ← All 52 queries
│
├── results/
│   ├── Q9_overall_kpis.png
│   ├── Q11_revenue_by_category.png
│   ├── Q12_monthly_revenue_trend.png
│   ├── Q13_revenue_by_city.png
│   ├── Q17_full_order_details.png
│   ├── Q28_mom_revenue_growth.png
│   ├── Q31_abc_customer_segmentation.png
│   ├── Q34_product_rank_by_category.png
│   ├── Q41_pivot_city_category.png
│   └── Q50_executive_kpi_dashboard.png
│
└── README.md
```

---

## 🗄️ Database Schema

This project uses a **fully normalized relational database** with 5 tables:

```
customers ──────────── orders ──────────── order_items
    │                     │                      │
customer_id (PK)      order_id (PK)        order_item_id (PK)
customer_name         customer_id (FK)     order_id (FK)
city                  order_date           product_id (FK)
signup_date           total_amount         quantity
                          │                unit_price
                          │
                       payments                products
                          │                      │
                    payment_id (PK)        product_id (PK)
                    order_id (FK)          product_name
                    payment_method         category
                    amount                 price
                    payment_date
```

### Table Details

| Table | Columns | Description |
|---|---|---|
| `customers` | customer_id, customer_name, city, signup_date | Customer master data |
| `orders` | order_id, customer_id, order_date, total_amount | Order header info |
| `order_items` | order_item_id, order_id, product_id, quantity, unit_price | Line items per order |
| `products` | product_id, product_name, category, price | Product catalog |
| `payments` | payment_id, order_id, payment_method, amount, payment_date | Payment records |

---

## 🎯 Project Objectives

- Perform end-to-end ecommerce analysis using **pure SQL**
- Answer real business questions with actionable insights
- Demonstrate proficiency across **all SQL complexity levels**
- Show multi-table JOIN design, window functions, CTEs, views & stored procedures

---

## 📊 SQL Techniques Demonstrated

| # | Section | Queries | Key Concepts |
|---|---|---|---|
| 1 | Basic Queries | Q1 – Q8 | `SELECT`, `WHERE`, `LIKE`, `ORDER BY`, `LIMIT`, date filters |
| 2 | Aggregation | Q9 – Q16 | `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, revenue % |
| 3 | Joins | Q17 – Q22 | `INNER JOIN`, `LEFT JOIN`, `SELF JOIN`, multi-table queries |
| 4 | Subqueries | Q23 – Q27 | Correlated, scalar, `NOT IN`, nested subqueries |
| 5 | CTEs | Q28 – Q33 | `WITH` clause, chained CTEs, cohort analysis, Pareto |
| 6 | Window Functions | Q34 – Q40 | `RANK`, `DENSE_RANK`, `NTILE`, `LAG`, `LEAD`, `PERCENT_RANK`, `FIRST_VALUE` |
| 7 | Advanced Analytics | Q41 – Q49 | Pivot tables, Z-score anomaly detection, ABC segmentation, discount analysis |
| 8 | Views & Procedures | Q50 – Q52 | Executive KPI dashboard, `CREATE VIEW`, Stored Procedure |

---

## 🔍 Business Questions Answered

### 📦 Sales & Revenue
- What is the total revenue, average order value, and order count?
- Which product categories generate the most revenue?
- What is the month-over-month revenue growth trend?
- What does the weekly sales performance look like?
- Which orders are anomalies based on Z-score analysis?

### 👥 Customer Analysis
- Who are the top customers by lifetime value?
- Which customers have never placed an order?
- How do we segment customers (One-Time / Returning / Loyal)?
- What is the average days between purchases per customer?
- Which city has the highest average order value?

### 🛍️ Product Analysis
- Which products are top sellers by quantity and revenue?
- Which products have never been ordered?
- Are products being sold at a discount vs listed price?
- Which products are frequently bought together? (Market Basket)
- Which products drive 80% of revenue? (Pareto Analysis)

### 💳 Payment Analysis
- Which payment methods are most popular?
- Which orders have not been paid yet? (Revenue at risk)
- What is the average payment per method?

### 📈 Advanced Analytics
- ABC customer segmentation by spending (A/B/C tiers)
- Pareto analysis — top 20% products = 80% revenue
- Cohort analysis — revenue by customer signup month
- Pivot table — revenue by category per city
- Rolling 3-month average revenue trend

---

## 📸 Query Results

### Overall KPI Dashboard
![KPI Dashboard](results/Q9_overall_kpis.png)

### Revenue by Category
![Revenue by Category](results/Q11_revenue_by_category.png)

### Monthly Revenue Trend
![Monthly Trend](results/Q12_monthly_revenue_trend.png)

### ABC Customer Segmentation
![ABC Segmentation](results/Q31_abc_customer_segmentation.png)

### Product Rank Within Category (Window Function)
![Product Rank](results/Q34_product_rank_by_category.png)

---

## 💡 Key Findings

> *(Update these with your actual numbers after running the queries)*

- **Total Revenue**: ₹X,XX,XXX across XX orders
- **Top Category**: Electronics contributes XX% of total revenue
- **Top Customer**: [Name] with ₹XX,XXX lifetime spend
- **Best Month**: [Month YYYY] — ₹XX,XXX revenue
- **Unpaid Orders**: X orders worth ₹XX,XXX still unpaid
- **Pareto Confirmed**: Top X products drive 80% of revenue
- **Most Used Payment**: [Method] used in XX% of transactions

---

## 🛠️ How to Run

**Step 1** — Open MySQL Workbench and select the database:
```sql
USE ecommerce_db;
```

**Step 2** — Open `Ecommerce_SQL_Project_52_Queries.sql`

**Step 3** — Run queries section by section (ordered simple → complex)

**Step 4** — Use the Stored Procedure:
```sql
CALL GetTopCustomersByCity('New York', 5);
```

**Step 5** — Query the dashboard View:
```sql
SELECT * FROM vw_order_summary ORDER BY order_date DESC;
```

> ✅ Compatible with **MySQL 8.0+**

---

## 🧠 Code Highlights

```sql
-- Window Function: Rank products within category (Q34)
RANK() OVER (PARTITION BY category ORDER BY SUM(revenue) DESC)

-- CTE: Month-over-month growth (Q28)
WITH monthly AS (...), growth AS (SELECT ..., LAG(revenue) OVER (...))
SELECT month, growth_pct FROM growth;

-- ABC Segmentation (Q31)
CASE
  WHEN cum_pct <= 70 THEN 'A — High Value'
  WHEN cum_pct <= 90 THEN 'B — Mid Value'
  ELSE                    'C — Low Value'
END AS customer_segment

-- Pivot Table (Q41)
SUM(CASE WHEN category = 'Electronics' THEN revenue ELSE 0 END) AS Electronics

-- Z-Score Anomaly Detection (Q42)
ROUND((total_amount - AVG) / STDDEV, 2) AS z_score
```

---

## 🏷️ Topics
`sql` `mysql` `data-analysis` `ecommerce` `window-functions` `cte` `portfolio-project` `retail-analytics` `data-analytics`

---

*This project is part of my data analytics portfolio demonstrating end-to-end SQL skills for real-world business analysis.*
