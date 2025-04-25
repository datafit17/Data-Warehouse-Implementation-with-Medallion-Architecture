USE DW_Orders;
GO

IF OBJECT_ID('gold.vw_sales_by_region_category_year', 'V') IS NOT NULL
    DROP VIEW gold.vw_sales_by_region_category_year;
GO

CREATE OR ALTER VIEW gold.vw_sales_by_region_category_year AS
SELECT
    pl.region,
    pr.category,
    YEAR(fo.order_date) AS sales_year,
    SUM(fo.sales) AS total_sales,
    SUM(fo.profit) AS total_profit,
    SUM(fo.quantity) AS total_quantity
FROM gold.fact_orders fo
JOIN gold.dim_place pl ON fo.postal_code = pl.postal_code
JOIN gold.dim_products pr ON fo.product_id = pr.product_id
GROUP BY pl.region, pr.category, YEAR(fo.order_date);




