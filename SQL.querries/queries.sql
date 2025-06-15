-- 1. Total Sales Revenue
SELECT SUM(total_sales) AS total_revenue 
FROM amazon_sales_1000;

-- 2. Top 5 Cities by Revenue
SELECT city, SUM(total_sales) AS revenue 
FROM amazon_sales_1000
GROUP BY city 
ORDER BY revenue DESC 
LIMIT 5;

-- 3. Total Orders by Payment Method
SELECT payment_method, COUNT(*) AS total_orders 
FROM amazon_sales_1000
GROUP BY payment_method;

-- 4. Average Quantity Sold per Product
SELECT product, AVG(quantity) AS avg_quantity 
FROM amazon_sales_1000
GROUP BY product;

-- 5. Total Sales per Category
SELECT category, SUM(total_sales) AS category_sales 
FROM amazon_sales_1000
GROUP BY category;

-- 6. Top 3 Selling Products by Revenue
SELECT product, SUM(total_sales) AS revenue 
FROM amazon_sales_1000
GROUP BY product 
ORDER BY revenue DESC 
LIMIT 3;

-- 7. Total Number of Orders per City
SELECT city, COUNT(order_id) AS total_orders 
FROM amazon_sales_1000
GROUP BY city;

-- 8. Revenue Trends Over Months
SELECT MONTH(order_date) AS month, SUM(total_sales) AS monthly_revenue
FROM amazon_sales_1000 
GROUP BY MONTH(order_date);

-- 9. Most Used Payment Method in Delhi
SELECT payment_method, COUNT(*) AS method_count 
FROM amazon_sales_1000
WHERE city = 'Delhi' 
GROUP BY payment_method 
ORDER BY method_count DESC;

-- 10. Orders with Quantity More Than 3
SELECT * 
FROM amazon_sales_1000 
WHERE quantity > 3;

-- 11. Orders Between Two Dates
SELECT * 
FROM amazon_sales_1000
WHERE order_date BETWEEN '2024-01-01' AND '2024-06-01';

-- 12. Total Revenue by Product and City
SELECT product, city, SUM(total_sales) AS revenue 
FROM amazon_sales_1000
GROUP BY product, city 
ORDER BY revenue DESC;

-- 13. Average Price of Products by Category
SELECT category, AVG(price) AS avg_price 
FROM amazon_sales_1000
GROUP BY category;

-- 14. Find Duplicate Orders (if any)
SELECT order_id, COUNT(*) 
FROM amazon_sales_1000
GROUP BY order_id 
HAVING COUNT(*) > 1;

-- 15. Top Payment Method by Revenue
SELECT payment_method, SUM(total_sales) AS revenue 
FROM amazon_sales_1000
GROUP BY payment_method 
ORDER BY revenue DESC;
