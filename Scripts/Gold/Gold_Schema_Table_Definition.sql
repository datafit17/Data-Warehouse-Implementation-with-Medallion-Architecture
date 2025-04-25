USE master;
GO

-- =============================================
-- GOLD SCHEMA CREATION SCRIPT
-- Structured for production deployment
-- Implements a star schema for sales analytics
-- =============================================

-- STEP 1: Create 'gold' schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Gold schema created successfully';
END
ELSE
BEGIN
    PRINT 'Gold schema already exists';
END
GO

-- =============================================
-- STEP 2: Drop existing tables (if any)
-- Drop fact table first to avoid FK conflicts
-- =============================================

IF OBJECT_ID('gold.fact_orders', 'U') IS NOT NULL
    DROP TABLE gold.fact_orders;
GO

IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;
GO

IF OBJECT_ID('gold.dim_place', 'U') IS NOT NULL
    DROP TABLE gold.dim_place;
GO

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;
GO

-- =============================================
-- STEP 3: Create dimension tables
-- =============================================

-- Products dimension
CREATE TABLE gold.dim_products (
    product_id NVARCHAR(50) NOT NULL,
    category NVARCHAR(50) NOT NULL,
    subcategory NVARCHAR(50) NOT NULL,
    product_name NVARCHAR(250) NOT NULL,
    CONSTRAINT pk_dim_products PRIMARY KEY (product_id)
);
PRINT 'Products dimension table created';
GO

-- Place dimension
CREATE TABLE gold.dim_place (
    postal_code INT NOT NULL,
    city NVARCHAR(50) NOT NULL,
    state_reg NVARCHAR(50) NOT NULL,
    region NVARCHAR(50) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_place PRIMARY KEY (postal_code)
);
PRINT 'Place dimension table created';
GO

-- Customers dimension
CREATE TABLE gold.dim_customers (
    customer_id NVARCHAR(50) NOT NULL,
    customer_name NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_customers PRIMARY KEY (customer_id)
);
PRINT 'Customers dimension table created';
GO

-- =============================================
-- STEP 4: Create fact table with foreign keys
-- =============================================

CREATE TABLE gold.fact_orders (
    row_id INT NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NULL,
    ship_mode NVARCHAR(50) NULL,
    customer_id NVARCHAR(50) NOT NULL,
    segment NVARCHAR(50) NULL,
    postal_code INT NULL,
    product_id NVARCHAR(50) NOT NULL,
    sales FLOAT NOT NULL,
    quantity INT NOT NULL,
    discount FLOAT NULL,
    profit FLOAT NULL,
    CONSTRAINT pk_fact_orders PRIMARY KEY (row_id),
    CONSTRAINT fk_fact_orders_customers FOREIGN KEY (customer_id) 
        REFERENCES gold.dim_customers(customer_id),
    CONSTRAINT fk_fact_orders_place FOREIGN KEY (postal_code) 
        REFERENCES gold.dim_place(postal_code),
    CONSTRAINT fk_fact_orders_products FOREIGN KEY (product_id) 
        REFERENCES gold.dim_products(product_id)
);
PRINT 'Orders fact table created with referential integrity';
GO

-- =============================================
-- STEP 5: Create indexes on foreign keys and dates
-- Improves performance on analytical queries
-- =============================================

CREATE INDEX ix_fact_orders_customer_id ON gold.fact_orders(customer_id);
CREATE INDEX ix_fact_orders_postal_code ON gold.fact_orders(postal_code);
CREATE INDEX ix_fact_orders_product_id ON gold.fact_orders(product_id);
CREATE INDEX ix_fact_orders_order_date ON gold.fact_orders(order_date);
PRINT 'Performance indexes created';
GO

-- =============================================
-- STEP 6: Validation - show all tables in gold schema
-- =============================================

SELECT 
    t.name AS table_name,
    s.name AS schema_name,
    SUM(p.rows) AS row_count
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE s.name = 'gold' AND p.index_id IN (0, 1)
GROUP BY t.name, s.name
ORDER BY t.name;
GO

PRINT 'Gold schema creation completed successfully';



