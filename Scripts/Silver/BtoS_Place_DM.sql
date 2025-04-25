USE DW_Orders;
GO

-- 1. REGION STANDARDIZATION FUNCTION
-- Función para estandarizar valores de región

IF OBJECT_ID('dbo.StandardizeRegion', 'FN') IS NOT NULL
    DROP FUNCTION dbo.StandardizeRegion;
GO

CREATE FUNCTION dbo.StandardizeRegion (@inputRegion NVARCHAR(100))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @result NVARCHAR(50);
    
    -- Convert to lowercase and trim whitespace
    SET @inputRegion = LOWER(LTRIM(RTRIM(@inputRegion)));
    
    -- Standardize based on first two characters
    -- Estandariza basado en los primeros dos caracteres
    SET @result = CASE 
        WHEN LEFT(@inputRegion, 2) = 'ea' THEN 'east'
        WHEN LEFT(@inputRegion, 2) = 'we' THEN 'west'
        WHEN LEFT(@inputRegion, 2) = 'ce' THEN 'central'
        WHEN LEFT(@inputRegion, 2) = 'so' THEN 'south'
        ELSE 'east' -- Default value if no match
    END;
    
    RETURN @result;
END;
GO

-- 2. DATA MIGRATION EXECUTION
-- Ejecución de la migración de datos

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- INSERT NEW RECORDS (with data cleansing)
    -- Inserta nuevos registros (con limpieza de datos)
    INSERT INTO silver.place (
        postal_code,
        city,
        state_reg,
        region,
        country
    )
    SELECT 
        postal_code,
        LTRIM(RTRIM(city)), -- cleaned city
        LTRIM(RTRIM(state_reg)), -- cleaned state_reg
        dbo.StandardizeRegion(region) AS region, -- Standardized region
        LTRIM(RTRIM(country)) -- cleaned country
    FROM bronze.place;
    
    DECLARE @inserted_count INT = @@ROWCOUNT;
    PRINT 'Successfully migrated ' + CAST(@inserted_count AS VARCHAR) + ' records.';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'ERROR during migration:';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;

-- 3. CLEANUP
-- Limpieza

-- Drop the temporary function
-- Elimina la función temporal
DROP FUNCTION StandardizeRegion;
GO

