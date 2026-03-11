create database RetailDB;
use RetailDB;

--customers table
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    age INT,
    age_group VARCHAR(20),
    signup_date DATE
);


--product table
CREATE TABLE products(
    product_id VARCHAR(50) PRIMARY KEY,
    cost_price FLOAT,
    unit_price FLOAT
);

--stores table 
CREATE TABLE stores(
    store_id VARCHAR(50) PRIMARY KEY,
    operating_cost FLOAT
);

---salesdata
CREATE TABLE salesdata(
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id INT,
    product_id VARCHAR(50),
    store_id VARCHAR(50),
    order_date DATE,
    quantity INT,
    unit_price FLOAT,
    discount_pct FLOAT,
    total_amount FLOAT,
    profit FLOAT,
    order_month INT,
    order_year INT,
    sales_channel VARCHAR(50),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

--returns table
CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    return_date DATE,
    FOREIGN KEY (order_id) REFERENCES salesdata(order_id)
);

SELECT COUNT(*) FROM sales_cleaned ;
SELECT COUNT(*) FROM customers_cleaned;
SELECT COUNT(*) FROM products_cleaned;
SELECT COUNT(*) FROM stores_cleaned;
SELECT COUNT(*) FROM returns_cleaned;

--1.Total Revenue in Last 12 Months
SELECT SUM(revenue) AS total_revenue
FROM sales_cleaned
WHERE order_date >= DATEADD(MONTH, -12, GETDATE());


--2.Top 5 Best-Selling Products by Quantity
SELECT TOP 5 p.product_name,
       SUM(s.quantity) AS total_quantity
FROM sales_cleaned s
JOIN products_cleaned p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC;


--3.Customers from Each Region
SELECT region, COUNT(*) AS total_customers
FROM customers_cleaned
GROUP BY region;


--4.Store with Highest Profit in Past Year
SELECT TOP 1 st.store_name,
       SUM(s.profit) AS total_profit
FROM sales_cleaned s
JOIN stores_cleaned st ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY total_profit DESC;


--5.Return Rate by Product Category
SELECT p.category,
       COUNT(r.return_id) * 100.0 / COUNT(s.order_id) AS return_rate
FROM sales_cleaned s
JOIN products_cleaned p ON s.product_id = p.product_id
LEFT JOIN returns_cleaned r ON s.order_id = r.order_id
GROUP BY p.category;


--6.Average Revenue per Customer by Age Group
SELECT c.age_group,
       AVG(s.revenue) AS avg_revenue
FROM sales_cleaned s
JOIN customers_cleaned c ON s.customer_id = c.customer_id
GROUP BY c.age_group;


--7.More Profitable Sales Channel
SELECT sales_channel,
       AVG(profit) AS avg_profit
FROM sales_cleaned
GROUP BY sales_channel;

--8.Monthly Profit Trend (Last 2 Years) by Region
SELECT s.order_year,
       s.order_month,
       st.region,
       SUM(s.profit) AS monthly_profit
FROM sales_cleaned s
JOIN stores_cleaned st ON s.store_id = st.store_id
GROUP BY s.order_year, s.order_month, st.region
ORDER BY s.order_year, s.order_month;


--9.Top 3 Products with Highest Return Rate per Category
WITH ReturnRates AS (
    SELECT p.category,
           p.product_name,
           COUNT(r.return_id) * 100.0 / COUNT(s.order_id) AS return_rate,
           ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY COUNT(r.return_id) DESC) AS rn
    FROM sales_cleaned s
    JOIN products_cleaned p ON s.product_id = p.product_id
    LEFT JOIN returns_cleaned r ON s.order_id = r.order_id
    GROUP BY p.category, p.product_name
)
SELECT *
FROM ReturnRates
WHERE rn <= 3;


--10.Top 5 Customers by Total Profit + Tenure
SELECT TOP 5
       c.customer_id,
       SUM(sd.profit) AS Total_Profit,
       DATEDIFF(YEAR, c.signup_date, GETDATE()) AS Tenure_Years
FROM sales_cleaned sd
JOIN customers_cleaned c ON sd.customer_id = c.customer_id
GROUP BY c.customer_id, c.signup_date
ORDER BY Total_Profit DESC;







