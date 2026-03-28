/*
====================================================================
Product Report
====================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
1. Gathers essential fields such as product names. catagory,  subcatagory and cost.
2. Segments products by revenue to identify High-Performance, Mid-Range, or Low-Performance.
3. Aggregates customers- level metrics:
    - Total orders
    - Total sales
    - total quantity sold
    - total products (Unique)
    - lifespan ( in months)
4. Calculates valuables KPIS:
    - Recency (months since last sales)
    - Average order value  (AOR)
    - Average monthly spend
====================================================================
*/
CREATE VIEW gold.report_products AS
WITH base_query AS (
    /*
------------------------------------------------------------------- 
1) Base Query: Retrives core columns from tables
------------------------------------------------------------------- 
*/ 

SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.sub_category,
    p.cost

FROM gold.fact_sales f  
LEFT JOIN gold.dim_products p
ON  f.product_key = p.product_key
WHERE order_date IS NOT NULL
),

product_aggregations AS (
        /*
------------------------------------------------------------------- 
2) Aggrigate product-level metrics
------------------------------------------------------------------- 
*/ 

SELECT
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    DATEDIFF(MONTH, MIN(order_date) , Max(order_date)) AS life_span,
    MAX(order_date) AS latest_order_date,
    COUNT(DISTINCT order_number)AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1)AS avg_selling_price
FROM base_query
GROUP BY
product_key,
    product_name,
    category,
    sub_category,
    cost
)

    /*
------------------------------------------------------------------- 
3) Final Query: Combines all product results in to output
------------------------------------------------------------------- 
*/ 

SELECT
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    latest_order_date,
    DATEDIFF(MONTH, latest_order_date, GETDATE()) AS recency_in_month,
    CASE WHEN total_sales > 50000 THEN 'High Performer'
         WHEN total_sales >= 10000 THEN 'Mid-Range'
         ELSE 'Low-Performer'
    END AS product_segment,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
   -- Average Order Revenue (AOR) 
CASE
    WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
END avg_order_revenue,
-- Average Monthly revenue
CASE WHEN life_span = 0 then total_sales
     ELSE total_sales / life_span
END avg_monly_revenue

FROM product_aggregations


