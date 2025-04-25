USE DW_Orders;
GO

-- Drop the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_customer_segmentation')
    DROP VIEW gold.vw_customer_segmentation;
GO

-- Create the customer segmentation view
CREATE VIEW gold.vw_customer_segmentation
AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.row_id) AS total_orders,
    ROUND(SUM(o.sales),0) AS total_sales,
    ROUND(SUM(o.profit),0) AS total_profit,
    MAX(o.order_date) AS last_order_date,
    CASE 
        WHEN COUNT(o.row_id) > 20 THEN 'Premium'
        WHEN COUNT(o.row_id) BETWEEN 10 AND 19 THEN 'Regular'
        ELSE 'Occasional'
    END AS customer_segment
FROM 
    gold.dim_customers c
JOIN 
    gold.fact_orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.customer_name;
GO





