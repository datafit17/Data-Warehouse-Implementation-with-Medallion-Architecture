# Data-Warehouse-Implementation-with-Medallion-Architecture
This repository contains a SQL Server implementation of a medallion (bronze-silver-gold) architecture for sales data analysis.

DATASET STRUCTURE:
-Fact table: 
Orders - Transactional sales order data

-Dimension tables:
Products - Product master data
Place - Geographic reference data
Customers - Customer information

Architecture Layers
-Bronze:
Raw, unprocessed ingestion layer.
Preserves source data exactly as received.

-Silver:
Cleaned and standardized data.
Implements data quality checks.

-Gold:
Analysis-ready views
Optimized for reporting and visualization
Business-friendly transformations

Contents
SQL scripts for:

Schema creation
Data loading procedures
Data transformation pipelines
Quality validation checks
Sample datasets
Documentation

The implementation follows modern data warehousing best practices, enabling reliable analytics from raw data to business insights.

