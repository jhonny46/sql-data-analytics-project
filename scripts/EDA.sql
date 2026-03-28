
-- Dim Exploration
SELECT DISTINCT country FROM  gold.dim_customers; -- Country has a Null value. Go back to fix

-- Explore all Dimentions for product line 
SELECT DISTINCT category,sub_category, product_name FROM  gold.dim_products
ORDER BY 1,2,3;


--- Date Exploration 
-- Find the latest and the earliest order date
-- How Many years of sales are avialable ?

SELECT 
MIN(order_date) first_order_date,
MAX (order_date) last_order_date,
DATEDIFF(month, MIN(order_date), MAX (order_date)) As years_of_sale
FROM gold.fact_sales;

-- Find the youngest and oldest customer
SELECT 
MIN(birthdate) as oldest_customer,
MAX(birthdate) as youngest_customer,
DATEDIFF(YEAR,MIN(birthdate) , GETDATE()) oldest_age,
DATEDIFF(YEAR,MAX(birthdate) , GETDATE()) youngest_age
FROM gold.dim_customers

-- Explore the measures

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;
-- Find how many ithems are sold 
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;
-- Find the average selling price 
SELECT AVG(sales_amount) AS total_sales FROM gold.fact_sales;
-- Find the total number of orders
SELECT COUNT(order_number) AS total_number_of_orders FROM gold.fact_sales;
SELECT COUNT(Distinct order_number) AS total_number_of_orders FROM gold.fact_sales;
-- Find the total number of products
SELECT   COUNT(Distinctproduct_name) AS total_number_of_products FROM gold.dim_products;
SELECT  COUNT(Distinct product_name) AS total_number_of_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_number_of_customers FROM gold.dim_customers;
-- Find the total number of customers that have palced an order
SELECT COUNT(DISTINCT customer_key) AS total_num_cust_placed_order FROM gold.dim_customers;

-- GENERATING A REPORT FOR ALL BUSSINESS METRICS 
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity)FROM gold.fact_sales
UNION ALL
SELECT 'AVERAGE PRICE', AVG(sales_amount)  FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' ,COUNT(Distinct order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(Distinct product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers;

/* 
==========================================
    MAGNITUDE  ANALYSIS ( MEASURE BY DIMENSIONS)
    TOTAL SALES BY COUNTRY 
    TOTAL QUANNTITY BY CATEGROY 
    AVERAGE PRICE BY PRODUCT
    TOTAL ORDER BY CUSTOMERS 
==========================================
*/

-- FIND TOTAL CUSTOMERS BY COUNTRY 
SELECT  
country,
COUNT(customer_key) As total_customer
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customer DESC

-- FIND TOTAL CUSTOMER BY GENDER
SELECT 
gender,
COUNT(customer_key) As total_customer
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customer DESC

-- Find total product by category 

SELECT 
category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average costs in each category ?
SELECT 
category,
AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- What is the total revenue generated for each category ?
SELECT
pr.category,
SUM(sl.sales_amount) AS total_revenue
FROM gold.fact_sales sl 
LEFT JOIN gold.dim_products pr
on pr.product_key = sl.product_key
GROUP BY pr.category
ORDER BY total_revenue DESC

-- What is the total revenue genrated by each customer ?
SELECT
c.customer_key,
c.first_name,
c.last_name, 
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c 
ON c.customer_key = s.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY  total_revenue DESC

-- DISTRIBUTION OF SOLD ITHEMS ACROSS Country ?

SELECT 
c. country,
SUM(s.quantity) AS total_sold_items
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c 
ON c.customer_key = s.customer_key
GROUP BY
country
ORDER BY total_sold_items DESC

/*
===============================================
RANKING Analysis
===============================================
*/

-- Which 5 products genreate the highest revendue ?
SELECT TOP 5
pr.sub_category,
SUM(sl.sales_amount) AS total_revenue
FROM gold.fact_sales sl 
LEFT JOIN gold.dim_products pr
on pr.product_key = sl.product_key
GROUP BY pr.sub_category
ORDER BY total_revenue DESC

-- Ranking top 5 Products 

SELECT TOP 5
pr.product_name,
SUM(sl.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(sl .sales_amount)) AS rank_product
FROM gold.fact_sales sl 
LEFT JOIN gold.dim_products pr
on pr.product_key = sl.product_key
GROUP BY pr.product_name;



-- What are the 5 worst- performing products in terms of sales ?
SELECT TOP 5
pr.product_name, 
SUM(sl.sales_amount) AS total_revenue
FROM gold.fact_sales sl 
LEFT JOIN gold.dim_products pr
on pr.product_key = sl.product_key
GROUP BY pr.product_name
ORDER BY total_revenue 

-- Find the top customers who have genereated the highes revenue
SELECT 
c.customer_key,
c.first_name,
c.last_name, 
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c 
ON c.customer_key = s.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue desc


-- The 3 customers with the fewest orders placed  
 SELECT top 3
c.customer_key,
c.first_name,
c.last_name, 
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c 
ON c.customer_key = s.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY  total_orders 