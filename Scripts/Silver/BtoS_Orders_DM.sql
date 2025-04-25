USE DW_Orders;
GO

-- DATA MIGRATION SCRIPT: bronze.orders → silver.orders
-- Columns to migrate: order_id, ship_mode, customer_id, 
--                    segment, product_id, postal_code
-- Unique identifier: row_id
-- ==========================================================

-- 1. PRE-MIGRATION VERIFICATION

-- Check if both source and target tables exist
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'orders')
AND EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'orders')
BEGIN
    PRINT '✅ Both source and target tables exist. Proceeding with column structure verification...';

    -- Compare column types between source and target
    SELECT 
        b.COLUMN_NAME,
        b.DATA_TYPE AS bronze_type,
        s.DATA_TYPE AS silver_type,
        CASE 
            WHEN b.DATA_TYPE = s.DATA_TYPE THEN 'Match'
            ELSE 'Mismatch'
        END AS type_comparison
    FROM INFORMATION_SCHEMA.COLUMNS b
    JOIN INFORMATION_SCHEMA.COLUMNS s 
        ON b.COLUMN_NAME = s.COLUMN_NAME
    WHERE b.TABLE_NAME = 'orders' AND b.TABLE_SCHEMA = 'bronze'
      AND s.TABLE_NAME = 'orders' AND s.TABLE_SCHEMA = 'silver'
      AND b.COLUMN_NAME IN (
            'row_id', 'order_id', 'ship_mode', 
            'customer_id', 'segment', 'product_id', 'postal_code'
      );
END
ELSE
BEGIN
    PRINT '❌ ERROR: Source or target table does not exist. Aborting migration.';
    RETURN;
END

-- 2. COUNT RECORDS TO BE MIGRATED

DECLARE @source_count INT, @target_count INT;
DECLARE @new_records INT, @update_candidates INT;

-- Count total records in source and target
SELECT @source_count = COUNT(*) FROM bronze.orders;
SELECT @target_count = COUNT(*) FROM silver.orders;

-- Count records that exist in source but not in target (new)
SELECT @new_records = COUNT(*)
FROM bronze.orders b
LEFT JOIN silver.orders s ON b.row_id = s.row_id
WHERE s.row_id IS NULL;

-- Count records that exist in both tables (update candidates)
SELECT @update_candidates = COUNT(*)
FROM bronze.orders b
INNER JOIN silver.orders s ON b.row_id = s.row_id;

PRINT '📊 Records in bronze.orders: ' + CAST(@source_count AS VARCHAR);
PRINT '📊 Records in silver.orders: ' + CAST(@target_count AS VARCHAR);
PRINT '➕ New records to insert: ' + CAST(@new_records AS VARCHAR);
PRINT '♻️  Records to evaluate for update: ' + CAST(@update_candidates AS VARCHAR);


-- 3. DATA MIGRATION EXECUTION

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- INSERT NEW RECORDS
    PRINT '🚀 Starting insertion of new records...';

    INSERT INTO silver.orders (
        row_id, 
        order_id, 
        ship_mode, 
        customer_id, 
        segment, 
        product_id, 
        postal_code
    )
    SELECT 
        b.row_id, 
        b.order_id, 
        b.ship_mode, 
        b.customer_id, 
        b.segment, 
        b.product_id, 
        b.postal_code
    FROM bronze.orders b
    LEFT JOIN silver.orders s ON b.row_id = s.row_id
    WHERE s.row_id IS NULL;

    DECLARE @inserted_count INT = @@ROWCOUNT;
    PRINT '✅ Inserted ' + CAST(@inserted_count AS VARCHAR) + ' new records.';

    
    -- UPDATE EXISTING RECORDS (only if values differ)
    PRINT '🔁 Starting update of existing records...';

    UPDATE s
    SET 
        s.order_id    = b.order_id,
        s.ship_mode   = b.ship_mode,
        s.customer_id = b.customer_id,
        s.segment     = b.segment,
        s.product_id  = b.product_id,
        s.postal_code = b.postal_code
    FROM silver.orders s
    INNER JOIN bronze.orders b ON s.row_id = b.row_id
    WHERE 
        ISNULL(s.order_id, '')    <> ISNULL(b.order_id, '') OR
        ISNULL(s.ship_mode, '')   <> ISNULL(b.ship_mode, '') OR
        ISNULL(s.customer_id, '') <> ISNULL(b.customer_id, '') OR
        ISNULL(s.segment, '')     <> ISNULL(b.segment, '') OR
        ISNULL(s.product_id, '')  <> ISNULL(b.product_id, '') OR
        ISNULL(s.postal_code, '') <> ISNULL(b.postal_code, '');

    DECLARE @updated_count INT = @@ROWCOUNT;
    PRINT '✅ Updated ' + CAST(@updated_count AS VARCHAR) + ' existing records.';
    
    COMMIT TRANSACTION;
    PRINT '🎉 Migration completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '❌ ERROR during migration:';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Procedure: ' + COALESCE(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;


