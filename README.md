# Adventure Works Internet Sales Analysis

End-to-end sales analysis of Adventure Works Internet Sales (2010–2014) using Excel, Power BI, Tableau, and MySQL.

## Objective
Analyse internet sales over time and across products, customers, and regions to find what drives sales and where the business can improve.

## Tools
Excel, Power BI, Tableau, MySQL

## Dataset
- 8 tables, 60,398 sales rows (Sales_New + Sales_Old combined), 2010–2014

## Data Preparation
- Combined Sales_New and Sales_Old into one table (60,398 rows) with zero data loss
- Joined Product, Customer, and Territory data using lookups (Excel), JOINs (MySQL), and relationships (Power BI/Tableau)
- Built Year, Month, Quarter, and Financial Quarter fields from OrderDateKey
- Data quality issues found: trailing spaces in class, style, and product line codes; 276 of 606 products had no class; 448 products were never sold; unit price stored as text with blank placeholders

## Key Insights
- 2013 was the peak year at $16.35M in sales
- Sales consistently peak in Q4 (December)
- Mountain-200 models dominate the top 10 products
- Class H products drive 76% of sales
- Australia leads every region

## Recommendations
- Prioritize Class H products for stock and marketing spend
- Expand the Mountain-200 and Road-150 lines
- Study Australia's approach and apply the learnings to Canada and the UK
- Investigate low-performing regions (Central, Northeast, Southeast) to check if it is a real gap or a data mapping issue
- Align inventory and staffing ahead of the Q4 peak
- Complete the missing product class classification

## Files
- `Adventure_Works_Excel.xlsx` – Excel analysis and pivot dashboards
- `Adventure Work BI_2.pbix` – Power BI dashboard
- `Adventure_Works_Tableau_4_.twbx` – Tableau dashboard
- `Adventure Work _SQL_3.sql` – MySQL queries and KPIs
