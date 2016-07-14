 --****************** [ DWAdventureWorksLT2012Lab1 ETL Code ] *********************--
-- This file will flush and fill the sales data mart in the DWAdventureWorksLT2012Lab1 database
--***********************************************************************************************--
Use DWAdventureWorksLT2012v1;
go
 
--********************************************************************--
-- Drop Foreign Key Constraints
--********************************************************************--
ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesToDimProducts;

ALTER TABLE dbo.FactSales DROP CONSTRAINT 
	fkFactSalesToDimCustomers;

ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesOrderDateToDimDates;

ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesShipDateDimDates;			

--********************************************************************--
-- Clear Table Data
--********************************************************************--
TRUNCATE TABLE dbo.FactSales;
TRUNCATE TABLE dbo.DimCustomers;
TRUNCATE TABLE dbo.DimProducts; 
  
--********************************************************************--
-- Fill Dimension Tables
--********************************************************************--

-- DimCustomers
INSERT INTO [DWAdventureWorksLT2012v1].[dbo].[DimCustomers]
( [CustomerID]
, [ContactFullName]
, [CompanyName]
, [MainOfficeCity]
, [MainOfficeStateProvince]
, [MainOfficeCountryRegion]
)
-- Create an ETL Select Statement that will work with this Insert Command
go

-- DimProducts
INSERT INTO [DWAdventureWorksLT2012v1].[dbo].[DimProducts]
( [ProductID]
, [ProductName]
, [ProductNumber]
, [ProductColor]
, [ProductStandardCost]
, [ProductListPrice]
, [ProductSize]
, [ProductWeight]
, [ProductCategoryID]
, [ProductCategoryName]
)
-- Create an ETL Select Statement that will work with this Insert Command
go

--********************************************************************--
-- Fill Fact Tables
--********************************************************************--

-- Fill Fact Sales 
INSERT INTO [DWAdventureWorksLT2012v1].[dbo].[FactSales]
( [SalesOrderID]
, [SalesOrderDetailID]
, [CustomerKey]
, [ProductKey]
, [OrderDateKey]
, [ShipDateKey]
, [OrderQty]
, [UnitPrice]
, [UnitPriceDiscount]
)
-- Create an ETL Select Statement that will work with this Insert Command
go

--********************************************************************--
-- Replace Foreign Key Constraints
--********************************************************************--
ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesToDimProducts FOREIGN KEY (ProductKey) 
	REFERENCES dbo.DimProducts	(ProductKey);

ALTER TABLE dbo.FactSales ADD CONSTRAINT 
	fkFactSalesToDimCustomers FOREIGN KEY (CustomerKey) 
	REFERENCES dbo.DimCustomers (CustomerKey);
 
ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesOrderDateToDimDates FOREIGN KEY (OrderDateKey) 
	REFERENCES dbo.DimDates(CalendarDateKey);

ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesShipDateDimDates FOREIGN KEY (ShipDateKey)
	REFERENCES dbo.DimDates (CalendarDateKey);
 
 
--********************************************************************--
-- Verify that the tables are filled
--********************************************************************--
-- Dimension Tables
SELECT * FROM [DWAdventureWorksLT2012v1].[dbo].[DimCustomers]; 
SELECT * FROM [DWAdventureWorksLT2012v1].[dbo].[DimDates]; 
SELECT * FROM [DWAdventureWorksLT2012v1].[dbo].[DimProducts]; 
-- Fact Tables 
SELECT * FROM [DWAdventureWorksLT2012v1].[dbo].[FactSales]; 
