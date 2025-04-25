USE DW_Orders;
GO

-- ==========================================================
-- DATA INTEGRITY CHECK: silver.orders
-- Verifica:
--   1. Valores nulos en row_id
--   2. Valores duplicados en row_id
-- ==========================================================


-- TABLE: SILVER.ORDERS
-- 1. Null values in row_id
IF EXISTS (SELECT 1 FROM silver.orders WHERE row_id IS NULL)
BEGIN
    PRINT '⚠️ Se encontraron registros con row_id NULL:';
    
    SELECT * 
    FROM silver.orders
    WHERE row_id IS NULL;
END
ELSE
BEGIN
    PRINT '✅ No hay registros con row_id NULL.';
END

-- 2. Duplicated row_id
IF EXISTS (
    SELECT row_id 
    FROM silver.orders
    GROUP BY row_id
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '⚠️ Se encontraron row_id duplicados:';
    
    WITH DuplicateCTE AS (
        SELECT 
            row_id,
            COUNT(*) OVER (PARTITION BY row_id) AS duplicate_count
        FROM silver.orders
    )
    SELECT 
        o.*,
        d.duplicate_count
    FROM silver.orders o
    JOIN DuplicateCTE d ON o.row_id = d.row_id
    WHERE d.duplicate_count > 1
    ORDER BY o.row_id;
END
ELSE
BEGIN
    PRINT '✅ No hay row_id duplicados.';
END


-- TABLE: SILVER.PLACE
-- 1. Null values in postal_code
IF EXISTS (SELECT 1 FROM silver.place WHERE postal_code IS NULL)
BEGIN
    PRINT '⚠️ Se encontraron registros con postal_code NULL:';
    
    SELECT * 
    FROM silver.place
    WHERE postal_code IS NULL;
END
ELSE
BEGIN
    PRINT '✅ No hay registros con postal_code NULL.';
END

-- 2. Duplicated postal_code
IF EXISTS (
    SELECT postal_code 
    FROM silver.place
    GROUP BY postal_code
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '⚠️ Se encontraron postal_code duplicados:';
    
    WITH DuplicateCTE AS (
        SELECT 
            postal_code,
            COUNT(*) OVER (PARTITION BY postal_code) AS duplicate_count
        FROM silver.place
    )
    SELECT 
        p.*,
        d.duplicate_count
    FROM silver.place p
    JOIN DuplicateCTE d ON p.postal_code = d.postal_code
    WHERE d.duplicate_count > 1
    ORDER BY p.postal_code;
END
ELSE
BEGIN
    PRINT '✅ No hay postal_code duplicados.';
END

-- TABLE: SILVER.PRODUCTS

-- 1. Null values in product_id
IF EXISTS (SELECT 1 FROM silver.products WHERE product_id IS NULL)
BEGIN
    PRINT '⚠️ Se encontraron registros con product_id NULL:';
    
    SELECT * 
    FROM silver.products
    WHERE product_id IS NULL;
END
ELSE
BEGIN
    PRINT '✅ No hay registros con product_id NULL.';
END

-- 2. Duplicated product_id
IF EXISTS (
    SELECT product_id 
    FROM silver.products
    GROUP BY product_id
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '⚠️ Se encontraron product_id duplicados:';
    
    WITH DuplicateCTE AS (
        SELECT 
            product_id,
            COUNT(*) OVER (PARTITION BY product_id) AS duplicate_count
        FROM silver.products
    )
    SELECT 
        p.*,
        d.duplicate_count
    FROM silver.products p
    JOIN DuplicateCTE d ON p.product_id = d.product_id
    WHERE d.duplicate_count > 1
    ORDER BY p.product_id;
END
ELSE
BEGIN
    PRINT '✅ No hay product_id duplicados.';
END



-- TABLE: SILVER.CUSTOMERS

-- 1. Null values in customer_id
IF EXISTS (SELECT 1 FROM silver.customers WHERE customer_id IS NULL)
BEGIN
    PRINT '⚠️ Se encontraron registros con customer_id NULL:';
    
    SELECT * 
    FROM silver.customers
    WHERE customer_id IS NULL;
END
ELSE
BEGIN
    PRINT '✅ No hay registros con customer_id NULL.';
END

-- 2. Duplicated customer_id
IF EXISTS (
    SELECT customer_id 
    FROM silver.customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '⚠️ Se encontraron customer_id duplicados:';
    
    WITH DuplicateCTE AS (
        SELECT 
            customer_id,
            COUNT(*) OVER (PARTITION BY customer_id) AS duplicate_count
        FROM silver.customers
    )
    SELECT 
        c.*,
        d.duplicate_count
    FROM silver.customers c
    JOIN DuplicateCTE d ON c.customer_id = d.customer_id
    WHERE d.duplicate_count > 1
    ORDER BY c.customer_id;
END
ELSE
BEGIN
    PRINT '✅ No hay customer_id duplicados.';
END




