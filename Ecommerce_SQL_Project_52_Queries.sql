-- ============================================================
--  ECOMMERCE DATABASE — INDUSTRY LEVEL SQL PROJECT
--  Author  : Dipali
--  Database: ecommerce_db
--  Tables  : customers, orders, order_items, products, payments
--
--  SCHEMA OVERVIEW:
--  customers  : customer_id, customer_name, city, signup_date
--  orders     : order_id, customer_id, order_date, total_amount
--  order_items: order_item_id, order_id, product_id, quantity, unit_price
--  products   : product_id, product_name, category, price
--  payments   : payment_id, order_id, payment_method, amount, payment_date
-- ============================================================

USE ecommerce_db;

-- ============================================================
-- SECTION 1 : BASIC QUERIES
-- ============================================================

-- Q1. List all customers with their city and signup date
SELECT customer_id, customer_name, city, signup_date
FROM customers
ORDER BY signup_date;

-- Q2. All orders placed in 2023
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE YEAR(order_date) = 2023
ORDER BY order_date;

-- Q3. Top 10 most expensive products
SELECT product_name, category, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Q4. All products in the Electronics category
SELECT product_id, product_name, price
FROM products
WHERE category = 'Electronics'
ORDER BY price DESC;

-- Q5. Customers who signed up in the last 6 months
SELECT customer_id, customer_name, city, signup_date
FROM customers
WHERE signup_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY signup_date DESC;

-- Q6. Orders with total amount greater than 500
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE total_amount > 500
ORDER BY total_amount DESC;

-- Q7. Find all unique cities where customers are from
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- Q8. Products whose name contains 'Pro' (search filter)
SELECT product_id, product_name, category, price
FROM products
WHERE LOWER(product_name) LIKE '%pro%';

-- ============================================================
-- SECTION 2 : AGGREGATION & GROUP BY
-- ============================================================

-- Q9. Overall business KPIs
SELECT
    COUNT(DISTINCT c.customer_id)          AS total_customers,
    COUNT(DISTINCT o.order_id)             AS total_orders,
    SUM(o.total_amount)                    AS total_revenue,
    ROUND(AVG(o.total_amount), 2)          AS avg_order_value,
    MAX(o.total_amount)                    AS largest_order,
    MIN(o.total_amount)                    AS smallest_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q10. Total revenue per customer (Customer Lifetime Value)
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id)           AS total_orders,
    SUM(o.total_amount)         AS lifetime_value,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY lifetime_value DESC;

-- Q11. Revenue by product category
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)            AS total_orders,
    SUM(oi.quantity)                       AS units_sold,
    SUM(oi.quantity * oi.unit_price)       AS category_revenue,
    ROUND(AVG(oi.unit_price), 2)           AS avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Q12. Monthly revenue trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m')   AS month,
    COUNT(order_id)                     AS total_orders,
    SUM(total_amount)                   AS monthly_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Q13. Revenue by city
SELECT
    c.city,
    COUNT(DISTINCT c.customer_id)       AS customers,
    COUNT(o.order_id)                   AS total_orders,
    SUM(o.total_amount)                 AS city_revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY city_revenue DESC;

-- Q14. Top 5 best-selling products by quantity
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                    AS total_units_sold,
    SUM(oi.quantity * oi.unit_price)    AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_units_sold DESC
LIMIT 5;

-- Q15. Payment method distribution
SELECT
    payment_method,
    COUNT(*)                                                          AS total_payments,
    SUM(amount)                                                       AS total_amount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments), 2)     AS pct_share
FROM payments
GROUP BY payment_method
ORDER BY total_payments DESC;

-- Q16. Average order value by city
SELECT
    c.city,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    COUNT(o.order_id)             AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING COUNT(o.order_id) >= 2
ORDER BY avg_order_value DESC;

-- ============================================================
-- SECTION 3 : JOINS
-- ============================================================

-- Q17. Full order details — customer + order + product
SELECT
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)  AS line_total
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
ORDER BY o.order_date DESC;

-- Q18. Orders with payment info (LEFT JOIN to catch unpaid)
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    COALESCE(pay.payment_method, 'Not Paid') AS payment_method,
    COALESCE(pay.amount, 0)                  AS amount_paid
FROM orders o
LEFT JOIN payments pay ON o.order_id = pay.order_id
ORDER BY o.order_date;

-- Q19. Customers who have NEVER placed an order
SELECT c.customer_id, c.customer_name, c.city, c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q20. Products that have NEVER been ordered
SELECT p.product_id, p.product_name, p.category, p.price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- Q21. Each customer's most recent order
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
)
ORDER BY o.order_date DESC;

-- Q22. Products bought together in the same order (Market Basket)
SELECT
    p1.product_name   AS product_a,
    p2.product_name   AS product_b,
    COUNT(*)          AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id   = oi2.order_id
                     AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) >= 2
ORDER BY times_bought_together DESC;

-- ============================================================
-- SECTION 4 : SUBQUERIES
-- ============================================================

-- Q23. Customers who spent above average order value
SELECT c.customer_name, c.city, o.order_id, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY o.total_amount DESC;

-- Q24. The highest revenue generating product
SELECT product_name, category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(oi.quantity * oi.unit_price) = (
    SELECT MAX(prod_rev)
    FROM (
        SELECT SUM(quantity * unit_price) AS prod_rev
        FROM order_items
        GROUP BY product_id
    ) t
);

-- Q25. Cities with above-average number of customers
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
HAVING COUNT(*) > (
    SELECT AVG(city_count)
    FROM (SELECT COUNT(*) AS city_count FROM customers GROUP BY city) t
);

-- Q26. Orders that include products from more than one category
SELECT o.order_id, o.order_date, COUNT(DISTINCT p.category) AS categories_in_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
GROUP BY o.order_id, o.order_date
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY categories_in_order DESC;

-- Q27. Second most expensive product per category
SELECT category, product_name, price
FROM products p1
WHERE price = (
    SELECT MAX(price)
    FROM products p2
    WHERE p2.category = p1.category
      AND p2.price < (SELECT MAX(price) FROM products p3 WHERE p3.category = p1.category)
)
ORDER BY category;

-- ============================================================
-- SECTION 5 : CTEs
-- ============================================================

-- Q28. Month-over-month revenue growth
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount)                 AS revenue
    FROM orders
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
    ROUND((revenue - prev_revenue) * 100.0 / prev_revenue, 2) AS growth_pct,
    CASE
        WHEN revenue > prev_revenue THEN '↑ Growth'
        WHEN revenue < prev_revenue THEN '↓ Decline'
        ELSE '→ Flat'
    END AS trend
FROM growth
WHERE prev_revenue IS NOT NULL
ORDER BY month;

-- Q29. Top 3 customers by revenue per city
WITH customer_rev AS (
    SELECT
        c.city,
        c.customer_name,
        SUM(o.total_amount) AS total_spent,
        RANK() OVER (PARTITION BY c.city ORDER BY SUM(o.total_amount) DESC) AS city_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.city, c.customer_id, c.customer_name
)
SELECT city, customer_name, total_spent, city_rank
FROM customer_rev
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- Q30. Running total of revenue by date
WITH daily AS (
    SELECT order_date, SUM(total_amount) AS daily_revenue
    FROM orders
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total
FROM daily
ORDER BY order_date;

-- Q31. ABC Customer Segmentation by spending
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
cumulative AS (
    SELECT *,
           SUM(total_spent) OVER (ORDER BY total_spent DESC) AS cum_spent,
           SUM(total_spent) OVER ()                           AS grand_total
    FROM customer_spend
)
SELECT
    customer_name,
    total_spent,
    ROUND(cum_spent * 100.0 / grand_total, 2) AS cum_pct,
    CASE
        WHEN cum_spent * 100.0 / grand_total <= 70 THEN 'A — High Value'
        WHEN cum_spent * 100.0 / grand_total <= 90 THEN 'B — Mid Value'
        ELSE                                             'C — Low Value'
    END AS customer_segment
FROM cumulative
ORDER BY total_spent DESC;

-- Q32. Products contributing to 80% of revenue (Pareto)
WITH prod_rev AS (
    SELECT
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
cumulative AS (
    SELECT *,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS cum_revenue,
           SUM(revenue) OVER ()                       AS total_revenue
    FROM prod_rev
)
SELECT product_name, category, revenue,
       ROUND(cum_revenue * 100.0 / total_revenue, 2) AS cum_pct
FROM cumulative
WHERE cum_revenue * 100.0 / total_revenue <= 80
ORDER BY revenue DESC;

-- Q33. Customer cohort analysis — revenue by signup month
WITH cohort AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
        SUM(o.total_amount)                  AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, cohort_month
)
SELECT
    cohort_month,
    COUNT(customer_id)       AS customers_acquired,
    SUM(total_spent)         AS cohort_revenue,
    ROUND(AVG(total_spent), 2) AS avg_spend_per_customer
FROM cohort
GROUP BY cohort_month
ORDER BY cohort_month;

-- ============================================================
-- SECTION 6 : WINDOW FUNCTIONS
-- ============================================================

-- Q34. Rank products by revenue within each category
SELECT
    p.category,
    p.product_name,
    SUM(oi.quantity * oi.unit_price)                                            AS revenue,
    RANK()       OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS revenue_rank,
    DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS dense_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category, p.product_id, p.product_name
ORDER BY p.category, revenue_rank;

-- Q35. Percentile rank of each customer by spending
SELECT
    c.customer_name,
    c.city,
    SUM(o.total_amount)                                                AS total_spent,
    ROUND(PERCENT_RANK() OVER (ORDER BY SUM(o.total_amount)) * 100, 2) AS spending_percentile
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_spent DESC;

-- Q36. Segment customers into spending quartiles
SELECT
    c.customer_name,
    c.city,
    SUM(o.total_amount)                                    AS total_spent,
    NTILE(4) OVER (ORDER BY SUM(o.total_amount) DESC)     AS spending_quartile
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY spending_quartile, total_spent DESC;

-- Q37. Compare each order's value to customer's own average (LAG)
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    ROUND(AVG(o.total_amount) OVER (PARTITION BY c.customer_id), 2) AS customer_avg,
    LAG(o.total_amount)  OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS prev_order,
    LEAD(o.total_amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS next_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name, o.order_date;

-- Q38. Rolling 3-month average revenue
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount)                 AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    ROUND(AVG(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3m_avg
FROM monthly
ORDER BY month;

-- Q39. First and last order per customer
SELECT DISTINCT
    c.customer_name,
    c.city,
    FIRST_VALUE(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)       AS first_order_date,
    FIRST_VALUE(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date DESC)  AS last_order_date,
    COUNT(o.order_id) OVER (PARTITION BY c.customer_id)                                      AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;

-- Q40. Revenue contribution % of each order within its customer total
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (PARTITION BY c.customer_id)                  AS customer_total,
    ROUND(o.total_amount * 100.0 /
          SUM(o.total_amount) OVER (PARTITION BY c.customer_id), 2)        AS pct_of_customer_total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name, pct_of_customer_total DESC;

-- ============================================================
-- SECTION 7 : ADVANCED ANALYTICS
-- ============================================================

-- Q41. Pivot — revenue by category per city
SELECT
    c.city,
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS Electronics,
    ROUND(SUM(CASE WHEN p.category = 'Fashion'     THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS Fashion,
    ROUND(SUM(CASE WHEN p.category = 'Grocery'     THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS Grocery,
    ROUND(SUM(CASE WHEN p.category = 'Books'       THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS Books,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                                                        AS Grand_Total
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY Grand_Total DESC;

-- Q42. Z-score anomaly detection on order amounts
WITH stats AS (
    SELECT AVG(total_amount) AS mean, STDDEV(total_amount) AS std
    FROM orders
)
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount,
    ROUND((o.total_amount - s.mean) / s.std, 2) AS z_score,
    CASE
        WHEN ABS((o.total_amount - s.mean) / s.std) > 2 THEN '🚨 Anomaly'
        ELSE 'Normal'
    END AS flag
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id, stats s
ORDER BY z_score DESC;

-- Q43. Customer retention — who ordered more than once?
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS order_count,
    CASE
        WHEN COUNT(o.order_id) = 1 THEN 'One-Time Buyer'
        WHEN COUNT(o.order_id) BETWEEN 2 AND 4 THEN 'Returning Customer'
        ELSE 'Loyal Customer'
    END AS customer_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY order_count DESC;

-- Q44. Days between orders per customer (purchase frequency)
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS prev_order_date,
    DATEDIFF(o.order_date,
             LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)
    ) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name, o.order_date;

-- Q45. Revenue per order item — which line items drive the most value?
SELECT
    oi.order_item_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)                                     AS line_revenue,
    ROUND((oi.quantity * oi.unit_price) * 100.0 /
          SUM(oi.quantity * oi.unit_price) OVER (), 4)                AS pct_of_total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY line_revenue DESC;

-- Q46. Payment success rate by method
SELECT
    payment_method,
    COUNT(*)                        AS total_payments,
    SUM(amount)                     AS total_collected,
    ROUND(AVG(amount), 2)           AS avg_payment,
    MAX(amount)                     AS max_payment,
    MIN(amount)                     AS min_payment
FROM payments
GROUP BY payment_method
ORDER BY total_collected DESC;

-- Q47. Orders not yet paid (revenue at risk)
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    o.total_amount AS amount_due
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments pay ON o.order_id = pay.order_id
WHERE pay.payment_id IS NULL
ORDER BY o.total_amount DESC;

-- Q48. Product price vs actual selling price comparison (discount detection)
SELECT
    p.product_name,
    p.category,
    p.price                             AS listed_price,
    ROUND(AVG(oi.unit_price), 2)        AS avg_selling_price,
    ROUND(p.price - AVG(oi.unit_price), 2)            AS avg_discount,
    ROUND((p.price - AVG(oi.unit_price)) * 100.0
          / p.price, 2)                 AS discount_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
HAVING AVG(oi.unit_price) < p.price
ORDER BY discount_pct DESC;

-- Q49. Weekly sales performance
SELECT
    YEAR(order_date)                    AS year,
    WEEK(order_date)                    AS week_number,
    MIN(order_date)                     AS week_start,
    COUNT(order_id)                     AS orders,
    SUM(total_amount)                   AS weekly_revenue
FROM orders
GROUP BY YEAR(order_date), WEEK(order_date)
ORDER BY year, week_number;

-- Q50. Executive KPI Dashboard — single summary view
WITH revenue AS (SELECT SUM(total_amount) AS total FROM orders),
     orders_cnt AS (SELECT COUNT(*) AS total FROM orders),
     customers_cnt AS (SELECT COUNT(*) AS total FROM customers),
     top_customer AS (
         SELECT c.customer_name, SUM(o.total_amount) AS spent
         FROM customers c JOIN orders o ON c.customer_id = o.customer_id
         GROUP BY c.customer_id, c.customer_name
         ORDER BY spent DESC LIMIT 1
     ),
     top_product AS (
         SELECT p.product_name, SUM(oi.quantity * oi.unit_price) AS rev
         FROM products p JOIN order_items oi ON p.product_id = oi.product_id
         GROUP BY p.product_id, p.product_name
         ORDER BY rev DESC LIMIT 1
     ),
     top_city AS (
         SELECT c.city, SUM(o.total_amount) AS rev
         FROM customers c JOIN orders o ON c.customer_id = o.customer_id
         GROUP BY c.city ORDER BY rev DESC LIMIT 1
     )
SELECT
    r.total                          AS total_revenue,
    oc.total                         AS total_orders,
    ROUND(r.total / oc.total, 2)     AS avg_order_value,
    cc.total                         AS total_customers,
    tc.customer_name                 AS top_customer,
    tc.spent                         AS top_customer_spend,
    tp.product_name                  AS top_product,
    tp.rev                           AS top_product_revenue,
    ci.city                          AS top_city
FROM revenue r, orders_cnt oc, customers_cnt cc, top_customer tc, top_product tp, top_city ci;

-- ============================================================
-- SECTION 8 : VIEWS & STORED PROCEDURES
-- ============================================================

-- Q51. Create a reusable VIEW for order summary dashboard
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)    AS line_total,
    o.total_amount,
    pay.payment_method
FROM orders o
JOIN customers c  ON o.customer_id  = c.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
JOIN products p   ON oi.product_id  = p.product_id
LEFT JOIN payments pay ON o.order_id = pay.order_id;

-- Use the view
SELECT * FROM vw_order_summary ORDER BY order_date DESC;

-- Q52. Stored Procedure — Get top N customers by city
DELIMITER $$
CREATE PROCEDURE GetTopCustomersByCity(
    IN p_city VARCHAR(50),
    IN p_limit INT
)
BEGIN
    SELECT
        c.customer_name,
        c.city,
        COUNT(o.order_id)           AS total_orders,
        SUM(o.total_amount)         AS total_spent,
        ROUND(AVG(o.total_amount), 2) AS avg_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.city = p_city
    GROUP BY c.customer_id, c.customer_name, c.city
    ORDER BY total_spent DESC
    LIMIT p_limit;
END$$
DELIMITER ;

-- Usage:
-- CALL GetTopCustomersByCity('New York', 5);
-- CALL GetTopCustomersByCity('Chicago', 3);

-- ============================================================
-- END OF PROJECT
-- 52 Queries | 8 Sections | 5 Tables
-- Skills: DDL · Joins · Subqueries · CTEs · Window Functions ·
--         Aggregation · Advanced Analytics · Views · Stored Procedures
-- ============================================================
