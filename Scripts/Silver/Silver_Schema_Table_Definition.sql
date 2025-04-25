/*
================================================================================
DDL Script: Silver Schema Table Definition  
================================================================================
Description:  
    Creates tables within the 'silver' schema. If any tables already exist,  
    they will be dropped and recreated.  
    Execute this script to reset the table structure in the 'silver' layer.  
================================================================================
*/  

USE DW_Orders;
GO

IF OBJECT_ID('silver.orders', 'U') IS NOT NULL
    DROP TABLE silver.orders;
GO

CREATE TABLE silver.orders (
    row_id		INT,
    order_id		NVARCHAR(50),
    order_date		DATE,
    ship_date		DATE,
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

IF OBJECT_ID('silver.products', 'U') IS NOT NULL
    DROP TABLE silver.products;
GO

CREATE TABLE silver.products (
    product_id		NVARCHAR(50),
    category		NVARCHAR(50),
    subcategory		NVARCHAR(50),
    product_name	NVARCHAR(250)
);
GO

IF OBJECT_ID('silver.place', 'U') IS NOT NULL
    DROP TABLE silver.place;
GO

CREATE TABLE silver.place (
    postal_code		INT,
    city  	            NVARCHAR(50),
    state_reg  		NVARCHAR(50),
    region 		NVARCHAR(50),
    country    		NVARCHAR(50)
);
GO

IF OBJECT_ID('silver.customers', 'U') IS NOT NULL
    DROP TABLE silver.customers;
GO

CREATE TABLE silver.customers (
    customer_id		NVARCHAR(50),
    customer_name		NVARCHAR(50)
);
GO