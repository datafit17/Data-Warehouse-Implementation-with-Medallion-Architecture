-- ==========================================================
-- DATA CLEANSING AND MIGRATION SCRIPT: bronze.products → silver.products
-- Columns to migrate: product_id, category, subcategory, product_name
-- Data transformation rules:
--   - category and subcategory converted to lowercase
--   - category values standardized to: 'furniture', 'office supplies', 'technology'
--   - product_id used as unique identifier
-- ==========================================================

USE DW_Orders;
GO

-- 1. DATA VALIDATION FUNCTION
-- Función para estandarizar categorías

-- Create function to standardize category values
-- Crea función para estandarizar valores de categoría
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'StandardizeCategory')
    DROP FUNCTION StandardizeCategory;
GO

CREATE FUNCTION StandardizeCategory (@inputCategory NVARCHAR(100))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @result NVARCHAR(50);
    
    -- Convert to lowercase and trim whitespace
    SET @inputCategory = LOWER(LTRIM(RTRIM(@inputCategory)));
    
    -- Standardize based on first two characters
    -- Estandariza basado en los primeros dos caracteres
    SET @result = CASE 
        WHEN LEFT(@inputCategory, 2) = 'fu' THEN 'furniture'
        WHEN LEFT(@inputCategory, 2) = 'of' THEN 'office supplies'
        WHEN LEFT(@inputCategory, 2) = 'te' THEN 'technology'
        ELSE 'furniture' -- Default value if no match
    END;
    
    RETURN @result;
END;
GO

-- 2. DATA MIGRATION EXECUTION
-- Ejecución de la migración de datos

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- INSERT NEW PRODUCTS (with data cleansing)
    -- Inserta nuevos productos (con limpieza de datos)
    INSERT INTO silver.products (
        product_id,
        category,
        subcategory,
        product_name
    )
    SELECT 
        b.product_id,
        dbo.StandardizeCategory(b.category) AS category, -- Standardized category
        LOWER(LTRIM(RTRIM(b.subcategory))) AS subcategory, -- Cleaned subcategory
        LTRIM(RTRIM(b.product_name)) -- Cleaned product_name
    FROM bronze.products b
    LEFT JOIN silver.products s ON b.product_id = s.product_id
    WHERE s.product_id IS NULL; -- Only insert new records
    
    DECLARE @new_records INT = @@ROWCOUNT;
    PRINT 'Inserted ' + CAST(@new_records AS VARCHAR) + ' new product records.';
    
    -- UPDATE EXISTING PRODUCTS (with data cleansing)
    -- Actualiza productos existentes (con limpieza de datos)
    UPDATE s
    SET 
        category = dbo.StandardizeCategory(b.category),
        subcategory = LOWER(LTRIM(RTRIM(b.subcategory))),
        product_name = LTRIM(RTRIM(b.product_name))
    FROM silver.products s
    INNER JOIN bronze.products b ON s.product_id = b.product_id;
    
    DECLARE @updated_records INT = @@ROWCOUNT;
    PRINT 'Updated ' + CAST(@updated_records AS VARCHAR) + ' existing product records.';
    
    COMMIT TRANSACTION;
    PRINT 'Product data migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'ERROR during product migration:';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;


-- 3. CLEANUP
-- Limpieza

-- Drop the temporary function
-- Elimina la función temporal
DROP FUNCTION StandardizeCategory;
GO


