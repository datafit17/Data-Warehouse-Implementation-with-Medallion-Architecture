USE DW_Orders;
GO

-- 1. DATA MIGRATION EXECUTION

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- INSERT NEW RECORDS (with data cleansing)
    INSERT INTO silver.customers (
        customer_id,
        customer_name
    )
    SELECT 
        customer_id,
        -- Clean leading/trailing spaces and reduce multiple spaces inside the name
        TRIM(REPLACE(REPLACE(REPLACE(customer_name, '  ', ' '), '  ', ' '), '  ', ' '))
    FROM bronze.customers;

    DECLARE @inserted_count INT = @@ROWCOUNT;
    PRINT 'Successfully migrated ' + CAST(@inserted_count AS VARCHAR) + ' records.';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    
    PRINT 'Error during data migration: ' + ERROR_MESSAGE();
END CATCH;


