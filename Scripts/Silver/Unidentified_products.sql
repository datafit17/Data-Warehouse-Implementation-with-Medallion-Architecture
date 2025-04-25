USE DW_Orders;
GO

-- =============================================
-- ORPHANED PRODUCT IDENTIFICATION QUERY
-- Finds product_ids in silver.orders with no match in silver.products
-- =============================================

-- Method 1: Basic identification of missing product_ids
SELECT DISTINCT 
    o.product_id AS orphaned_product_id	
FROM 
    silver.orders o
LEFT JOIN 
    silver.products p ON o.product_id = p.product_id
WHERE 
    p.product_id IS NULL;

-- Method 2: Detailed report with order counts
SELECT 
    o.product_id AS orphaned_product_id,	
    COUNT(o.order_id) AS order_count,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM 
    silver.orders o
LEFT JOIN 
    silver.products p ON o.product_id = p.product_id
WHERE 
    p.product_id IS NULL
GROUP BY 
    o.product_id
ORDER BY 
    order_count DESC;

-- Method 3: Complete order records with missing products
-- (Returns full order details for analysis)
SELECT 
    o.*
FROM 
    silver.orders o
LEFT JOIN 
    silver.products p ON o.product_id = p.product_id
WHERE 
    p.product_id IS NULL;



