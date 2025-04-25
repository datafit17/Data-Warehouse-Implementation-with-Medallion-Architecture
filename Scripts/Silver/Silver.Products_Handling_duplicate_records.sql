USE DW_Orders;
GO

-- =============================================
-- REMOVAL OF DUPLICATE RECORDS
-- Secure method that keeps a record of each duplicate
-- =============================================

-- 1. Check for duplicates:

WITH DuplicateCTE AS (
    SELECT 
        product_id,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY product_id) AS row_num,
        COUNT(*) OVER (PARTITION BY product_id) AS duplicate_count
    FROM silver.products
)
SELECT 
    product_id,
    duplicate_count
FROM DuplicateCTE
WHERE duplicate_count > 1
ORDER BY duplicate_count DESC;

-- 2. Secure duplicate removal
-- This method keeps a record of each set of duplicates

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Create a temporary table to store the IDs we want to keep
    -- (the first record of each set of duplicates)
    SELECT 
        product_id,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY product_id) AS row_num
    INTO #ProductsToKeep
    FROM silver.products;
    
    -- Show how many records will be deleted
    DECLARE @duplicatesToDelete INT = (SELECT COUNT(*) FROM #ProductsToKeep WHERE row_num > 1);
    PRINT 'Se eliminarán ' + CAST(@duplicatesToDelete AS VARCHAR) + ' registros duplicados';
    
    -- Remove duplicates (all except the first record in each group)
    DELETE FROM silver.products
    WHERE EXISTS (
        SELECT 1 
        FROM #ProductsToKeep k 
        WHERE silver.products.product_id = k.product_id 
        AND k.row_num > 1
    );
    
    -- Check results
    DECLARE @remainingRecords INT = (SELECT COUNT(*) FROM silver.products);
    PRINT 'Quedan ' + CAST(@remainingRecords AS VARCHAR) + ' registros únicos en la tabla';
    
    COMMIT TRANSACTION;
    PRINT 'Eliminación de duplicados completada exitosamente';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'Error al eliminar duplicados:';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH;

-- 3. Final check
-- Confirm that there are no more duplicates

SELECT 
    product_id, 
    COUNT(*) AS count
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1;