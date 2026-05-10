-- ============================================================
--  AMAZON RETAIL SQL PROJECT
--  Author  : Dipali
--  Dataset : amazon_sales_1000 (order_id, order_date, product,
--            category, price, quantity, total_sales, city,
--            payment_method)
--  Topics  : DDL · Cleaning · Basic · Aggregation · Joins ·
--            Subqueries · CTEs · Window Functions · Advanced
-- ============================================================


-- ============================================================
-- SECTION 0 : SCHEMA DESIGN & DDL
-- ============================================================

-- 0.1  Master sales table (matches your CSV exactly)
CREATE TABLE IF NOT EXISTS amazon_sales (
    order_id       VARCHAR(20)    PRIMARY KEY,
    order_date     DATE           NOT NULL,
    product        VARCHAR(100)   NOT NULL,
    category       VARCHAR(50)    NOT NULL,
    price          DECIMAL(10,2)  NOT NULL CHECK (price > 0),
    quantity       INT            NOT NULL CHECK (quantity > 0),
    total_sales    DECIMAL(12,2)  GENERATED ALWAYS AS (price * quantity) STORED,
    city           VARCHAR(50)    NOT NULL,
    payment_method VARCHAR(30)    NOT NULL
);

-- 0.2  Normalised supporting tables (show multi-table design)
CREATE TABLE IF NOT EXISTS dim_product (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(100) UNIQUE NOT NULL,
    category     VARCHAR(50)  NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_city (
    city_id   SERIAL PRIMARY KEY,
    city_name VARCHAR(50) UNIQUE NOT NULL,
    region    VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id       VARCHAR(20)   PRIMARY KEY,
    order_date     DATE          NOT NULL,
    product_id     INT           REFERENCES dim_product(product_id),
    city_id        INT           REFERENCES dim_city(city_id),
    price          DECIMAL(10,2) NOT NULL,
    quantity       INT           NOT NULL,
    total_sales    DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(30)   NOT NULL
);

-- ============================================================
-- SECTION 1 : DATA QUALITY & CLEANING
-- ============================================================

-- Q1. Check for duplicate order_ids
SELECT order_id, COUNT(*) AS occurrences
FROM amazon_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Q2. Find rows with NULL values in any critical column
SELECT *
FROM amazon_sales
WHERE order_id IS NULL
   OR order_date IS NULL
   OR product IS NULL
   OR city IS NULL
   OR price IS NULL
   OR quantity IS NULL;

-- Q3. Detect price/quantity mismatches (data integrity check)
SELECT order_id, price, quantity, total_sales,
       ROUND(price * quantity, 2)          AS calculated_sales,
       total_sales - ROUND(price * quantity, 2) AS discrepancy
FROM amazon_sales
WHERE ABS(total_sales - ROUND(price * quantity, 2)) > 0.01;

-- Q4. Standardise payment method values (trim & title-case)
UPDATE amazon_sales
SET payment_method = INITCAP(TRIM(payment_method));

-- Q5. Flag orders with suspiciously high quantity (outlier detection)
SELECT order_id, product, quantity
FROM amazon_sales
WHERE quantity > (
    SELECT AVG(quantity) + 3 * STDDEV(quantity) FROM amazon_sales
);

-- ============================================================
-- SECTION 2 : BASIC QUERIES — Filtering & Sorting
-- ============================================================

-- Q6. All orders placed in 2024
SELECT *
FROM amazon_sales
WHERE YEAR(order_date) = 2024
ORDER BY order_date;

-- Q7. Top 10 most expensive products ever sold
SELECT DISTINCT product, price
FROM amazon_sales
ORDER BY price DESC
LIMIT 10;

-- Q8. Orders paid via Credit Card in Mumbai
SELECT order_id, product, total_sales
FROM amazon_sales
WHERE payment_method = 'Credit Card'
  AND city = 'Mumbai'
ORDER BY total_sales DESC;

-- Q9. Products whose name contains "Phone" (case-insensitive)
SELECT DISTINCT product, category, price
FROM amazon_sales
WHERE LOWER(product) LIKE '%phone%';

-- Q10. Orders placed on weekends
SELECT order_id, order_date, product, total_sales,
       DAYNAME(order_date) AS day_name
FROM amazon_sales
WHERE DAYOFWEEK(order_date) IN (1, 7);   -- 1=Sunday, 7=Saturday

-- ============================================================
-- SECTION 3 : AGGREGATION & GROUP BY
-- ============================================================

-- Q11. Total revenue, total orders, average order value
SELECT
    COUNT(*)                    AS total_orders,
    SUM(total_sales)            AS total_revenue,
    ROUND(AVG(total_sales), 2)  AS avg_order_value,
    MIN(total_sales)            AS min_order,
    MAX(total_sales)            AS max_order
FROM amazon_sales;

-- Q12. Revenue and order count by category
SELECT
    category,
    COUNT(*)                           AS total_orders,
    SUM(total_sales)                   AS total_revenue,
    ROUND(AVG(total_sales), 2)         AS avg_order_value,
    ROUND(SUM(total_sales) * 100.0 /
        (SELECT SUM(total_sales) FROM amazon_sales), 2) AS revenue_pct
FROM amazon_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- Q13. Monthly revenue trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m')  AS month,
    COUNT(*)                           AS orders,
    SUM(total_sales)                   AS monthly_revenue
FROM amazon_sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Q14. Top 5 cities by total revenue
SELECT city, SUM(total_sales) AS city_revenue
FROM amazon_sales
GROUP BY city
ORDER BY city_revenue DESC
LIMIT 5;

-- Q15. Payment method distribution (count + revenue share)
SELECT
    payment_method,
    COUNT(*)                                                AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM amazon_sales), 2) AS pct_orders,
    SUM(total_sales)                                        AS total_revenue
FROM amazon_sales
GROUP BY payment_method
ORDER BY order_count DESC;

-- Q16. Products with total quantity sold > 50
SELECT product, SUM(quantity) AS units_sold
FROM amazon_sales
GROUP BY product
HAVING SUM(quantity) > 50
ORDER BY units_sold DESC;

-- Q17. Average price per category, only where avg price > 500
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM amazon_sales
GROUP BY category
HAVING AVG(price) > 500
ORDER BY avg_price DESC;

-- Q18. Day-of-week revenue pattern (which day earns most?)
SELECT
    DAYNAME(order_date)  AS day_name,
    COUNT(*)             AS orders,
    SUM(total_sales)     AS revenue
FROM amazon_sales
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY DAYOFWEEK(order_date);

-- ============================================================
-- SECTION 4 : SUBQUERIES
-- ============================================================

-- Q19. Orders above the overall average order value
SELECT order_id, product, total_sales
FROM amazon_sales
WHERE total_sales > (SELECT AVG(total_sales) FROM amazon_sales)
ORDER BY total_sales DESC;

-- Q20. The single best-selling product by revenue
SELECT product, SUM(total_sales) AS revenue
FROM amazon_sales
GROUP BY product
HAVING SUM(total_sales) = (
    SELECT MAX(prod_rev)
    FROM (SELECT SUM(total_sales) AS prod_rev FROM amazon_sales GROUP BY product) t
);

-- Q21. Cities that have never used "Cash on Delivery"
SELECT DISTINCT city
FROM amazon_sales
WHERE city NOT IN (
    SELECT DISTINCT city
    FROM amazon_sales
    WHERE payment_method = 'Cash on Delivery'
)
ORDER BY city;

-- Q22. Customers (cities) whose average order > overall average
SELECT city, ROUND(AVG(total_sales), 2) AS city_avg
FROM amazon_sales
GROUP BY city
HAVING AVG(total_sales) > (SELECT AVG(total_sales) FROM amazon_sales)
ORDER BY city_avg DESC;

-- Q23. Second highest revenue-generating category
SELECT category, SUM(total_sales) AS revenue
FROM amazon_sales
GROUP BY category
ORDER BY revenue DESC
LIMIT 1 OFFSET 1;

-- Q24. Products sold in ALL top-3 revenue cities
SELECT product
FROM amazon_sales
WHERE city IN (
    SELECT city FROM amazon_sales
    GROUP BY city ORDER BY SUM(total_sales) DESC LIMIT 3
)
GROUP BY product
HAVING COUNT(DISTINCT city) = 3;

-- ============================================================
-- SECTION 5 : CTEs (Common Table Expressions)
-- ============================================================

-- Q25. Month-over-month revenue growth rate
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_sales)                  AS revenue
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly
)
SELECT
    month,
    revenue,
    prev_revenue,
    ROUND((revenue - prev_revenue) * 100.0 / prev_revenue, 2) AS growth_pct
FROM growth
WHERE prev_revenue IS NOT NULL
ORDER BY month;

-- Q26. Category contribution using CTE
WITH category_rev AS (
    SELECT category, SUM(total_sales) AS cat_revenue
    FROM amazon_sales
    GROUP BY category
),
total AS (
    SELECT SUM(total_sales) AS grand_total FROM amazon_sales
)
SELECT
    c.category,
    c.cat_revenue,
    ROUND(c.cat_revenue * 100.0 / t.grand_total, 2) AS contribution_pct
FROM category_rev c, total t
ORDER BY c.cat_revenue DESC;

-- Q27. Identify top 3 products per category (CTE + RANK)
WITH ranked AS (
    SELECT
        category,
        product,
        SUM(total_sales)                                          AS revenue,
        RANK() OVER (PARTITION BY category ORDER BY SUM(total_sales) DESC) AS rnk
    FROM amazon_sales
    GROUP BY category, product
)
SELECT category, product, revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- Q28. Running total of revenue ordered by date (CTE)
WITH daily AS (
    SELECT order_date, SUM(total_sales) AS daily_revenue
    FROM amazon_sales
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total
FROM daily
ORDER BY order_date;

-- Q29. High-value orders (>2x avg) with their category rank
WITH avg_order AS (
    SELECT AVG(total_sales) AS overall_avg FROM amazon_sales
),
high_value AS (
    SELECT s.*, a.overall_avg
    FROM amazon_sales s, avg_order a
    WHERE s.total_sales > 2 * a.overall_avg
)
SELECT order_id, product, category, total_sales,
       RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS category_rank
FROM high_value
ORDER BY total_sales DESC;

-- ============================================================
-- SECTION 6 : WINDOW FUNCTIONS
-- ============================================================

-- Q30. Rank products by revenue within each category
SELECT
    category,
    product,
    SUM(total_sales)                                            AS revenue,
    RANK()     OVER (PARTITION BY category ORDER BY SUM(total_sales) DESC) AS rank_in_cat,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(total_sales) DESC) AS dense_rank_in_cat
FROM amazon_sales
GROUP BY category, product
ORDER BY category, rank_in_cat;

-- Q31. Rolling 3-month average revenue
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(total_sales) AS revenue
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3m_avg
FROM monthly
ORDER BY month;

-- Q32. Percentile rank of each order's value
SELECT
    order_id,
    product,
    total_sales,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_sales) * 100, 2) AS percentile_rank
FROM amazon_sales
ORDER BY total_sales DESC;

-- Q33. Lead/Lag — compare each order's revenue to the next/previous order (same city)
SELECT
    order_id,
    city,
    order_date,
    total_sales,
    LAG(total_sales)  OVER (PARTITION BY city ORDER BY order_date) AS prev_order_same_city,
    LEAD(total_sales) OVER (PARTITION BY city ORDER BY order_date) AS next_order_same_city
FROM amazon_sales
ORDER BY city, order_date;

-- Q34. Cumulative revenue as % of total (running contribution)
SELECT
    order_id,
    order_date,
    product,
    total_sales,
    ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0
          / SUM(total_sales) OVER (), 2)  AS cumulative_pct
FROM amazon_sales
ORDER BY total_sales DESC;

-- Q35. First and last order date per city
SELECT DISTINCT
    city,
    FIRST_VALUE(order_date) OVER (PARTITION BY city ORDER BY order_date)          AS first_order,
    FIRST_VALUE(order_date) OVER (PARTITION BY city ORDER BY order_date DESC)     AS last_order,
    COUNT(*) OVER (PARTITION BY city)                                              AS total_orders
FROM amazon_sales
ORDER BY city;

-- Q36. Divide orders into revenue quartiles (NTILE)
SELECT
    order_id,
    product,
    total_sales,
    NTILE(4) OVER (ORDER BY total_sales) AS revenue_quartile
FROM amazon_sales
ORDER BY revenue_quartile, total_sales DESC;

-- ============================================================
-- SECTION 7 : JOINS (using the normalised dim/fact tables)
-- ============================================================

-- Q37. Full product details joined from dim_product
SELECT
    fo.order_id,
    fo.order_date,
    dp.product_name,
    dp.category,
    fo.total_sales
FROM fact_orders fo
JOIN dim_product dp ON fo.product_id = dp.product_id
ORDER BY fo.order_date;

-- Q38. Orders with city region info (LEFT JOIN to keep all orders)
SELECT
    fo.order_id,
    dc.city_name,
    COALESCE(dc.region, 'Unknown') AS region,
    fo.total_sales
FROM fact_orders fo
LEFT JOIN dim_city dc ON fo.city_id = dc.city_id
ORDER BY dc.region, fo.total_sales DESC;

-- Q39. Revenue by region using JOIN + GROUP BY
SELECT
    COALESCE(dc.region, 'Unknown') AS region,
    COUNT(fo.order_id)             AS orders,
    SUM(fo.total_sales)            AS revenue
FROM fact_orders fo
LEFT JOIN dim_city dc ON fo.city_id = dc.city_id
GROUP BY dc.region
ORDER BY revenue DESC;

-- Q40. Self-join: find products that appear in both Electronics and Fashion
SELECT DISTINCT a.product
FROM amazon_sales a
JOIN amazon_sales b ON a.product = b.product
WHERE a.category = 'Electronics'
  AND b.category = 'Fashion';

-- ============================================================
-- SECTION 8 : ADVANCED ANALYTICS
-- ============================================================

-- Q41. ABC Analysis — classify products by revenue contribution
WITH prod_rev AS (
    SELECT product,
           SUM(total_sales) AS revenue
    FROM amazon_sales
    GROUP BY product
),
cumulative AS (
    SELECT product, revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS cum_rev,
           SUM(revenue) OVER ()                       AS total_rev
    FROM prod_rev
)
SELECT
    product,
    revenue,
    ROUND(cum_rev * 100.0 / total_rev, 2) AS cum_pct,
    CASE
        WHEN cum_rev * 100.0 / total_rev <= 70  THEN 'A - High Value'
        WHEN cum_rev * 100.0 / total_rev <= 90  THEN 'B - Mid Value'
        ELSE                                          'C - Low Value'
    END AS abc_class
FROM cumulative
ORDER BY revenue DESC;

-- Q42. Month-over-month revenue change with trend label
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(total_sales) AS revenue
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
          / LAG(revenue) OVER (ORDER BY month), 2) AS growth_pct,
    CASE
        WHEN revenue > LAG(revenue) OVER (ORDER BY month) THEN '↑ Growth'
        WHEN revenue < LAG(revenue) OVER (ORDER BY month) THEN '↓ Decline'
        ELSE '→ Flat'
    END AS trend
FROM monthly
ORDER BY month;

-- Q43. Cohort-style analysis: first purchase month vs. repeat orders
WITH first_order AS (
    SELECT city,
           MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort_month
    FROM amazon_sales
    GROUP BY city
)
SELECT
    f.cohort_month,
    COUNT(DISTINCT a.city)   AS cities_acquired,
    SUM(a.total_sales)       AS cohort_revenue
FROM first_order f
JOIN amazon_sales a ON f.city = a.city
GROUP BY f.cohort_month
ORDER BY f.cohort_month;

-- Q44. Pivot: revenue by category per payment method (CASE pivot)
SELECT
    payment_method,
    ROUND(SUM(CASE WHEN category = 'Electronics' THEN total_sales ELSE 0 END), 2) AS Electronics,
    ROUND(SUM(CASE WHEN category = 'Fashion'     THEN total_sales ELSE 0 END), 2) AS Fashion,
    ROUND(SUM(CASE WHEN category = 'Grocery'     THEN total_sales ELSE 0 END), 2) AS Grocery,
    ROUND(SUM(CASE WHEN category = 'Books'       THEN total_sales ELSE 0 END), 2) AS Books,
    ROUND(SUM(total_sales), 2)                                                      AS Grand_Total
FROM amazon_sales
GROUP BY payment_method
ORDER BY Grand_Total DESC;

-- Q45. Customer Lifetime Value proxy (city = proxy customer group)
SELECT
    city,
    COUNT(*)                         AS total_orders,
    SUM(total_sales)                 AS total_revenue,
    ROUND(AVG(total_sales), 2)       AS avg_order_value,
    MIN(order_date)                  AS first_order,
    MAX(order_date)                  AS last_order,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS active_days
FROM amazon_sales
GROUP BY city
ORDER BY total_revenue DESC;

-- Q46. Pareto Analysis: products driving 80% of revenue
WITH prod_rev AS (
    SELECT product, SUM(total_sales) AS revenue
    FROM amazon_sales
    GROUP BY product
),
running AS (
    SELECT product, revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS cum_rev,
           SUM(revenue) OVER ()                       AS total
    FROM prod_rev
)
SELECT product, revenue,
       ROUND(cum_rev * 100.0 / total, 2) AS cum_pct
FROM running
WHERE cum_rev * 100.0 / total <= 80
ORDER BY revenue DESC;

-- Q47. Seasonal index: compare each month's revenue to annual monthly average
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           MONTH(order_date)               AS month_num,
           SUM(total_sales)                AS revenue
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'), MONTH(order_date)
),
monthly_avg AS (
    SELECT AVG(revenue) AS avg_monthly FROM monthly
)
SELECT m.month, m.revenue,
       ROUND(m.revenue / ma.avg_monthly, 2) AS seasonal_index
FROM monthly m, monthly_avg ma
ORDER BY m.month;

-- Q48. Z-score anomaly detection on daily revenue
WITH daily AS (
    SELECT order_date, SUM(total_sales) AS revenue
    FROM amazon_sales
    GROUP BY order_date
),
stats AS (
    SELECT AVG(revenue) AS mean, STDDEV(revenue) AS std FROM daily
)
SELECT d.order_date, d.revenue,
       ROUND((d.revenue - s.mean) / s.std, 2) AS z_score,
       CASE WHEN ABS((d.revenue - s.mean) / s.std) > 2 THEN 'ANOMALY' ELSE 'Normal' END AS flag
FROM daily d, stats s
ORDER BY z_score DESC;

-- Q49. Market basket analysis proxy: products frequently bought in same city & date
SELECT
    a.product          AS product_a,
    b.product          AS product_b,
    COUNT(*)           AS co_occurrence_count
FROM amazon_sales a
JOIN amazon_sales b
    ON  a.city       = b.city
    AND a.order_date = b.order_date
    AND a.product    < b.product       -- avoid duplicates
GROUP BY a.product, b.product
HAVING COUNT(*) >= 3
ORDER BY co_occurrence_count DESC
LIMIT 20;

-- Q50. Executive KPI Dashboard Summary
WITH kpis AS (
    SELECT
        COUNT(*)                                                       AS total_orders,
        SUM(total_sales)                                               AS total_revenue,
        ROUND(AVG(total_sales), 2)                                     AS avg_order_value,
        COUNT(DISTINCT product)                                        AS unique_products,
        COUNT(DISTINCT city)                                           AS cities_served,
        COUNT(DISTINCT payment_method)                                 AS payment_methods,
        MAX(total_sales)                                               AS single_largest_order,
        SUM(quantity)                                                  AS units_sold
    FROM amazon_sales
),
best_month AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(total_sales) AS rev
    FROM amazon_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
    ORDER BY rev DESC LIMIT 1
),
top_cat AS (
    SELECT category FROM amazon_sales
    GROUP BY category ORDER BY SUM(total_sales) DESC LIMIT 1
),
top_city AS (
    SELECT city FROM amazon_sales
    GROUP BY city ORDER BY SUM(total_sales) DESC LIMIT 1
)
SELECT
    k.*,
    bm.month  AS best_revenue_month,
    bm.rev    AS best_month_revenue,
    tc.category  AS top_category,
    ci.city      AS top_city
FROM kpis k, best_month bm, top_cat tc, top_city ci;

-- Q51. BONUS — Stored Procedure: get top N products for any category
DELIMITER $$
CREATE PROCEDURE GetTopProducts(IN p_category VARCHAR(50), IN p_limit INT)
BEGIN
    SELECT product,
           SUM(total_sales)  AS revenue,
           SUM(quantity)     AS units_sold,
           COUNT(*)          AS order_count
    FROM amazon_sales
    WHERE category = p_category
    GROUP BY product
    ORDER BY revenue DESC
    LIMIT p_limit;
END$$
DELIMITER ;

-- Usage: CALL GetTopProducts('Electronics', 5);

-- Q52. BONUS — View: monthly category revenue for dashboards
CREATE OR REPLACE VIEW vw_monthly_category_revenue AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    category,
    COUNT(*)                          AS orders,
    SUM(total_sales)                  AS revenue,
    ROUND(AVG(total_sales), 2)        AS avg_order_value
FROM amazon_sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), category;

-- Query the view
SELECT * FROM vw_monthly_category_revenue ORDER BY month, revenue DESC;

-- ============================================================
-- END OF PROJECT
-- 52 queries covering: DDL, Cleaning, Basic, Aggregation,
-- Subqueries, CTEs, Window Functions, Joins, Advanced Analytics,
-- Stored Procedures, and Views
-- ============================================================
