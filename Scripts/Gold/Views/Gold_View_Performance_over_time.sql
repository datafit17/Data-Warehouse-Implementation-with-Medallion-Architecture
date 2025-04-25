USE DW_Orders;
GO

-- Drop the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_monthly_sales_analysis' AND schema_id = SCHEMA_ID('gold'))
    DROP VIEW gold.vw_monthly_sales_analysis;
GO

-- Create the monthly sales analysis view
CREATE VIEW gold.vw_monthly_sales_analysis
AS
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(row_id) AS total_orders,
    ROUND(SUM(sales), 0) AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(sales) / NULLIF(COUNT(row_id), 0), 2) AS avg_order_value,
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start_date
FROM 
    gold.fact_orders
GROUP BY 
    YEAR(order_date), MONTH(order_date);
GO



-- Example query to use the view with sorting
SELECT *
FROM gold.vw_monthly_sales_analysis
ORDER BY year DESC, month DESC;