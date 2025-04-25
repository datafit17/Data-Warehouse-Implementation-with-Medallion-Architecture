USE DW_Orders;
GO

-- Check for null values: postal_code

SELECT *
FROM silver.place
WHERE postal_code IS NULL;

-- Check for duplicates values

SELECT * 
FROM silver.place
WHERE postal_code =
(
SELECT 
    postal_code    
FROM silver.place
GROUP BY postal_code
HAVING COUNT(*) > 1
)


-- 2. Assign the correct value

--5401 corresponds to the Burlington, Vermont zip code.
UPDATE silver.place
SET postal_code = 5401
WHERE postal_code IS NULL
AND city = 'Burlington'
AND state_reg = 'Vermont';

--92023 corresponds to the Encinitas, California zip code.
UPDATE silver.place
SET postal_code = 92023
WHERE city = 'Encinitas'
AND state_reg = 'California';