USE DW_Orders;
GO

-- Drop the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_product_category_analysis' AND schema_id = SCHEMA_ID('gold'))
    DROP VIEW gold.vw_product_category_analysis;
GO

-- Create the product category analysis view
CREATE VIEW gold.vw_product_category_analysis
AS
SELECT 
    p.category,
    p.subcategory,
    COUNT(o.row_id) AS total_orders,
    ROUND(SUM(o.sales), 0) AS total_sales,
    ROUND(SUM(o.profit), 0) AS total_profit,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(o.sales) / NULLIF(COUNT(o.row_id), 0), 2) AS avg_order_value
FROM 
    gold.dim_products p
JOIN 
    gold.fact_orders o ON p.product_id = o.product_id
GROUP BY 
    p.category, p.subcategory;
GO

