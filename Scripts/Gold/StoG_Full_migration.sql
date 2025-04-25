USE DW_Orders;
GO

-- =============================================
-- GOLD DATA MIGRATION SCRIPT FROM SILVER
-- Description: Populates gold star schema tables
-- Author: [Your Name] | Date: [Current Date]
-- =============================================

-- =============================================
-- STEP 1: CLEAN TARGET TABLES
-- Delete data preserving referential integrity
-- =============================================

PRINT 'Cleaning gold tables before migration...';

-- Delete fact table data first to avoid FK violations
DELETE FROM gold.fact_orders;

-- Then delete dimensions (order matters)
DELETE FROM gold.dim_customers;
DELETE FROM gold.dim_place;
DELETE FROM gold.dim_products;

-- =============================================
-- STEP 2: LOAD DIMENSION TABLES
-- Insert distinct records from silver schema
-- =============================================

-- Products dimension
PRINT 'Inserting data into gold.dim_products...';
INSERT INTO gold.dim_products (product_id, category, subcategory, product_name)
SELECT DISTINCT product_id, category, subcategory, product_name
FROM silver.products;

PRINT 'dim_products populated.';

-- Place dimension
PRINT 'Inserting data into gold.dim_place...';
INSERT INTO gold.dim_place (postal_code, city, state_reg, region, country)
SELECT DISTINCT postal_code, city, state_reg, region, country
FROM silver.place;

PRINT 'dim_place populated.';

-- Customers dimension
PRINT 'Inserting data into gold.dim_customers...';
INSERT INTO gold.dim_customers (customer_id, customer_name)
SELECT DISTINCT customer_id, customer_name
FROM silver.customers;

PRINT 'dim_customers populated.';

-- =============================================
-- STEP 3: LOAD FACT TABLE
-- Insert data with FK validation from silver.orders
-- =============================================

PRINT 'Inserting data into gold.fact_orders...';

INSERT INTO gold.fact_orders (
    row_id, order_id, order_date, ship_date, ship_mode, customer_id,
    segment, postal_code, product_id, sales, quantity, discount, profit
)
SELECT 
    o.row_id, o.order_id, o.order_date, o.ship_date, o.ship_mode,
    o.customer_id, o.segment, o.postal_code, o.product_id,
    o.sales, o.quantity, o.discount, o.profit
FROM silver.orders o
WHERE o.customer_id IN (SELECT customer_id FROM gold.dim_customers)
  AND o.product_id IN (SELECT product_id FROM gold.dim_products)
  AND o.postal_code IN (SELECT postal_code FROM gold.dim_place);

PRINT 'fact_orders populated.';

-- =============================================
-- STEP 4: VALIDATION
-- Confirm row counts
-- =============================================

PRINT 'Verifying record counts in gold tables...';

SELECT 
    t.name AS table_name,
    s.name AS schema_name,
    p.rows AS row_count
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE s.name = 'gold' AND p.index_id IN (0, 1)
GROUP BY t.name, s.name, p.rows
ORDER BY t.name;

PRINT 'Data migration from silver to gold completed successfully.';


