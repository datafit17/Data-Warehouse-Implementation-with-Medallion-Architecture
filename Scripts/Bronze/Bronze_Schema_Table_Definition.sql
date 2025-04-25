/*
================================================================================
DDL Script: Bronze Schema Table Definition  
================================================================================
Description:  
    Creates tables within the 'bronze' schema. If any tables already exist,  
    they will be dropped and recreated.  
    Execute this script to reset the table structure in the 'bronze' layer.  
================================================================================
*/  

USE DW_Orders;
GO

IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
    DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
    row_id		INT,
    order_id		NVARCHAR(50),
    order_date		NVARCHAR(50),
    ship_date		NVARCHAR(50),
    ship_mode		NVARCHAR(50),
    customer_id	NVARCHAR(50),
    segment		NVARCHAR(50),
    postal_code		INT,
    product_id		NVARCHAR(50),
    sales			FLOAT,
    quantity		INT,
    discount		FLOAT,
    profit		FLOAT     
);
GO

IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
    DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
    product_id		NVARCHAR(50),
    category		NVARCHAR(50),
    subcategory		NVARCHAR(50),
    product_name	NVARCHAR(250)
);
GO

IF OBJECT_ID('bronze.place', 'U') IS NOT NULL
    DROP TABLE bronze.place;
GO

CREATE TABLE bronze.place (
    postal_code		INT,
    city  	            NVARCHAR(50),
    state_reg  		NVARCHAR(50),
    region 		NVARCHAR(50),
    country    		NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers (
    customer_id		NVARCHAR(50),
    customer_name		NVARCHAR(50)
);
GO