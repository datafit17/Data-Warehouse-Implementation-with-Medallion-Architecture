/*
========================================================================
Database and Schema Initialization
========================================================================
Script Objective:  
    This script creates a new database named 'DW_Orders' after verifying  
    whether it already exists. If the database is present, it will be dropped  
    and recreated. The script also establishes three core schemas within the  
    database: 'bronze', 'silver', and 'gold'.  

CRITICAL WARNING:  
    Executing this script will permanently delete the entire 'DW_Orders'  
    database if it exists. All stored data will be irrecoverably lost.  
    Proceed with extreme caution and ensure you have verified backups  
    before running this script.  
*/

USE master;
GO

-- Drop and recreate the 'DW_Orders' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DW_Orders')
BEGIN
    ALTER DATABASE DW_Orders SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DW_Orders;
END;
GO

-- Create the 'DW_Orders' database
CREATE DATABASE DW_Orders;
GO

USE DW_Orders;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO