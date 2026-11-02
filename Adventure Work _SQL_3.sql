CREATE DATABASE adventure_works;
USE adventure_works; 
CREATE TABLE fact_combined AS SELECT * FROM factinternetsales UNION ALL SELECT * FROM fact_internet_sales_new; -- Question 0 (Combine two sales table)
SELECT COUNT(*) FROM fact_combined;

-- Question 1 (Product)
SELECT 
    f.*,
    p.EnglishProductName AS ProductName
FROM fact_combined f
LEFT JOIN dimproduct p 
    ON f.ProductKey = p.ProductKey;
    
    CREATE TABLE fact_step1 AS
SELECT 
    f.*,
    p.EnglishProductName AS ProductName
FROM fact_combined f
LEFT JOIN dimproduct p 
    ON f.ProductKey = p.ProductKey;
    
    SELECT * FROM fact_step1;  -- Question 1 complete 
    
    -- Question 2 (Customer Name + Unit Price)
    
    CREATE TABLE fact_step2 AS
SELECT 
    f.*,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice
FROM fact_step1 f
LEFT JOIN dimcustomer c 
    ON f.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct p 
    ON f.ProductKey = p.ProductKey;
    
    select*from fact_step2; 	-- question 2 compete 
    
    -- Question 3 (Data Fields)
    
    CREATE TABLE fact_step3 AS
SELECT 
    f.*,
    STR_TO_DATE(f.OrderDateKey, '%Y%m%d') AS DateField,
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS MonthNo,
    MONTHNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS MonthFullName,
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'))) AS Quarter,
    DATE_FORMAT(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,
    DAYOFWEEK(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS WeekdayNo,
    DAYNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS WeekdayName,
    CASE 
        WHEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) >= 7 
        THEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) - 6
        ELSE MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) + 6
    END AS FinancialMonth
FROM fact_step2 f;

ALTER TABLE fact_step3 ADD COLUMN FinancialQuarter VARCHAR(2);
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_step3 SET FinancialQuarter = CONCAT('Q', CEIL(FinancialMonth / 3));

select*from fact_step3; -- Question 3 complete 

-- Question 4, 5, 6 - Sales Amount, Production Cost, Profit


CREATE TABLE fact_step4 AS
SELECT 
    f.*,
    (f.UnitPrice * f.OrderQuantity * (1 - f.UnitPriceDiscountPct)) AS CalculatedSalesAmount,
    (f.ProductStandardCost * f.OrderQuantity) AS CalculatedProductionCost
FROM fact_step3 f;

ALTER TABLE fact_step4 ADD COLUMN Profit DECIMAL(15,2);
UPDATE fact_step4 SET Profit = CalculatedSalesAmount - CalculatedProductionCost; -- Question 4, 5, 6 complete 
select*from fact_step4;

-- Question 7 Month vs Sales Summery 

SELECT 
    Year,
    MonthFullName,
    SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step4
WHERE Year = 2013   -- 'Filter' ka equivalent (change karke koi bhi year daal sakte ho)
GROUP BY Year, MonthFullName
ORDER BY MIN(MonthNo);

-- Question 8 to 11 (Aggregation Queries)

-- Q8: Year-wise Sales 
SELECT Year, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step4   -- where year in (2012,2013), where year=2013 
GROUP BY Year
ORDER BY Year;

-- Q9: Month-wise Sales
SELECT MonthFullName, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step4
GROUP BY MonthFullName, MonthNo
ORDER BY MonthNo;

-- Q10: Quarter-wise Sales 
SELECT Quarter, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step4                         -- where Year=2013
GROUP BY Quarter
ORDER BY Quarter;

-- For comparing multipal years

SELECT 
    Year,
    Quarter, 
    SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step4
WHERE Year IN (2012, 2013)
GROUP BY Year, Quarter
ORDER BY Year, Quarter; 

-- Q11: Sales vs Production Cost, Month-wise
SELECT 
    MonthFullName, 
    SUM(CalculatedSalesAmount) AS TotalSales,
    SUM(CalculatedProductionCost) AS TotalProductionCost
FROM fact_step4
GROUP BY MonthFullName, MonthNo
ORDER BY MonthNo;

-- Question 12 KPIs

-- Region/Country and Class 
CREATE TABLE fact_step5 AS
SELECT 
    f.*,
    st.SalesTerritoryRegion AS Region,
    st.SalesTerritoryCountry AS Country,
    p.Class AS ProductClass
FROM fact_step4 f
LEFT JOIN dimsalesterritory st 
    ON f.SalesTerritoryKey = st.SalesTerritoryKey
LEFT JOIN dimproduct p 
    ON f.ProductKey = p.ProductKey;

-- Total Sales, Profit, Orders, Products, Customers
SELECT 
    SUM(CalculatedSalesAmount) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    COUNT(*) AS TotalOrders,
    (SELECT COUNT(*) FROM dimproduct) AS TotalProducts,
    (SELECT COUNT(*) FROM dimcustomer) AS TotalCustomers
FROM fact_step5;

SELECT 
    COUNT(*) AS TotalOrders   -- COUNT(*)
FROM fact_step5;
SELECT COUNT(*) FROM dimproduct;

-- Region-wise Sales & Profit
SELECT Region, Country, SUM(CalculatedSalesAmount) AS TotalSales, SUM(Profit) AS TotalProfit
FROM fact_step5
GROUP BY Region, Country
ORDER BY TotalSales DESC;

-- Class-wise Sales
SELECT ProductClass, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step5
GROUP BY ProductClass
ORDER BY TotalSales DESC;

-- Top 10 Products by Sales
SELECT ProductName, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step5
GROUP BY ProductName
ORDER BY TotalSales DESC
LIMIT 10;

-- Top 10 Customers by Sales
SELECT CustomerFullName, SUM(CalculatedSalesAmount) AS TotalSales
FROM fact_step5
GROUP BY CustomerFullName
ORDER BY TotalSales DESC
LIMIT 10;



