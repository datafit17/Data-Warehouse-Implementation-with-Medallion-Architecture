USE DW_Orders;
GO

-- ==========================================================
-- DATA MIGRATION SCRIPT: bronze.orders → silver.orders
-- Columns: sales, quantity, discount, profit
-- Validation rules:
--   - sales, quantity, discount must be non-negative (ABS)
--   - profit can be negative
-- ==========================================================

-- 1. PRE-MIGRATION VALIDATION
DECLARE @neg_sales INT, @neg_qty INT, @neg_disc INT;

SELECT 
    @neg_sales = COUNT(*) 
FROM bronze.orders WHERE sales < 0;

SELECT 
    @neg_qty = COUNT(*) 
FROM bronze.orders WHERE quantity < 0;

SELECT 
    @neg_disc = COUNT(*) 
FROM bronze.orders WHERE discount < 0;

PRINT '🔍 Pre-Migration Check:';
PRINT ' - Records with negative sales: ' + CAST(@neg_sales AS VARCHAR);
PRINT ' - Records with negative quantity: ' + CAST(@neg_qty AS VARCHAR);
PRINT ' - Records with negative discount: ' + CAST(@neg_disc AS VARCHAR);
PRINT '---------------------------------------------------';

-- 2. DATA TYPE VERIFICATION
PRINT '📋 Checking data type compatibility between bronze and silver...';

SELECT 
    b.COLUMN_NAME,
    b.DATA_TYPE AS bronze_type,
    s.DATA_TYPE AS silver_type,
    CASE 
        WHEN b.DATA_TYPE = s.DATA_TYPE THEN '✅ Match' 
        ELSE '❌ Mismatch' 
    END AS type_comparison
FROM INFORMATION_SCHEMA.COLUMNS b
JOIN INFORMATION_SCHEMA.COLUMNS s 
    ON b.COLUMN_NAME = s.COLUMN_NAME
WHERE 
    b.TABLE_NAME = 'orders' AND b.TABLE_SCHEMA = 'bronze'
    AND s.TABLE_NAME = 'orders' AND s.TABLE_SCHEMA = 'silver'
    AND b.COLUMN_NAME IN ('sales', 'quantity', 'discount', 'profit');

-- 3. MIGRATION EXECUTION
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '🚀 Starting data migration for numeric columns...';

    UPDATE s
    SET 
        s.sales = ABS(b.sales),
        s.quantity = ABS(b.quantity),
        s.discount = ABS(b.discount),
        s.profit = b.profit
    FROM silver.orders s
    INNER JOIN bronze.orders b ON s.row_id = b.row_id;

    DECLARE @updated_rows INT = @@ROWCOUNT;
    PRINT '✅ Updated ' + CAST(@updated_rows AS VARCHAR) + ' records in silver.orders.';

    -- Count number of values actually corrected (negatives turned to positives)
    DECLARE @corrected_values INT = 0;
    SELECT @corrected_values = COUNT(*)
    FROM bronze.orders
    WHERE sales < 0 OR quantity < 0 OR discount < 0;

    PRINT '🔄 Converted ' + CAST(@corrected_values AS VARCHAR) + ' negative values to absolute values.';

    COMMIT TRANSACTION;
    PRINT '🎉 Migration completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT '❌ ERROR during migration:';
    PRINT ' - Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT ' - Message: ' + ERROR_MESSAGE();
    PRINT ' - Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT ' - Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;

