USE DW_Orders;
GO

-- ===============================
-- 🗓️ DATE FORMAT CONVERSION
-- Source format assumed: DD/MM/YYYY (as text)
-- Target format: DATE (ISO: YYYY-MM-DD)
-- ===============================

-- Convert order_date
UPDATE s
SET s.order_date = TRY_CONVERT(
    DATE, 
    SUBSTRING(b.order_date, 7, 4) + '-' +  -- Año
    SUBSTRING(b.order_date, 4, 2) + '-' +  -- Mes
    SUBSTRING(b.order_date, 1, 2)          -- Día
)
FROM silver.orders s
INNER JOIN bronze.orders b ON s.row_id = b.row_id
WHERE b.order_date IS NOT NULL;
GO

-- Convert ship_date
UPDATE s
SET s.ship_date = TRY_CONVERT(
    DATE, 
    SUBSTRING(b.ship_date, 7, 4) + '-' +  -- Año
    SUBSTRING(b.ship_date, 4, 2) + '-' +  -- Mes
    SUBSTRING(b.ship_date, 1, 2)          -- Día
)
FROM silver.orders s
INNER JOIN bronze.orders b ON s.row_id = b.row_id
WHERE b.ship_date IS NOT NULL;
GO

-- ===============================
-- 🔎 CHECK FOR FAILED CONVERSIONS
-- ===============================

-- Records that failed order_date conversion
SELECT b.row_id, b.order_date
FROM bronze.orders b
JOIN silver.orders s ON b.row_id = s.row_id
WHERE s.order_date IS NULL AND b.order_date IS NOT NULL;

-- Conversion statistics
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN s.order_date IS NULL AND b.order_date IS NOT NULL THEN 1 ELSE 0 END) AS conversion_errors,
    SUM(CASE WHEN s.order_date IS NOT NULL THEN 1 ELSE 0 END) AS successful_conversions
FROM silver.orders s
JOIN bronze.orders b ON s.row_id = b.row_id;



