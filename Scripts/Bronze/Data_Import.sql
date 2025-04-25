/*
	Bulk data import from CSV files into target tables.
	
	Performs high-performance data loading using BULK INSERT with these configurations:
	- First row skipped (header row assumption)
	- Comma (,) as field separator
	- Table lock enabled for optimized import speed
	
	Note: File paths must be accessible to the SQL Server instance.
*/

USE DW_Orders;
GO

BULK INSERT bronze.orders
FROM 'C:\Users\Omar\Omar\Estudios\PROYECTOS\2025\Datasets Tableau\SQL Warehouse\Orders.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',
	TABLOCK
);
GO

BULK INSERT bronze.products
FROM 'C:\Users\Omar\Omar\Estudios\PROYECTOS\2025\Datasets Tableau\SQL Warehouse\Products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',
	TABLOCK
);
GO

BULK INSERT bronze.customers
FROM 'C:\Users\Omar\Omar\Estudios\PROYECTOS\2025\Datasets Tableau\SQL Warehouse\Customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',
	TABLOCK
);
GO

BULK INSERT bronze.place
FROM 'C:\Users\Omar\Omar\Estudios\PROYECTOS\2025\Datasets Tableau\SQL Warehouse\Location.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',
	TABLOCK
);
GO