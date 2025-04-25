USE DW_Orders;
GO

-- Drop the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_regional_sales_analysis' AND schema_id = SCHEMA_ID('gold'))
    DROP VIEW gold.vw_regional_sales_analysis;
GO

-- Create the regional sales analysis view
CREATE VIEW gold.vw_regional_sales_analysis
AS
SELECT 
    p.state_reg,
    p.region,
    COUNT(o.row_id) AS total_orders,
    ROUND(SUM(o.sales),0) AS total_sales,
    ROUND(SUM(o.profit),0) AS total_profit,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM 
    gold.dim_place p
JOIN 
    gold.fact_orders o ON p.postal_code = o.postal_code
GROUP BY 
    p.state_reg, p.region;
GO

