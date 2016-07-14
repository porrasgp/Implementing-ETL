--****************** [DWAdventureWorksLT2012Lab01] *********************--
-- This file will drop and create the DWAdventureWorksLT2012Lab01
-- database, with all its objects. 
--********************************************************************--

USE [master];
If Exists (Select Name from SysDatabases Where Name = 'DWAdventureWorksLT2012Lab01')
  Begin
   Alter database DWAdventureWorksLT2012Lab01 set single_user with rollback immediate;
   Drop database DWAdventureWorksLT2012Lab01;
  End
go
CREATE DATABASE DWAdventureWorksLT2012Lab01;
go
USE DWAdventureWorksLT2012Lab01;
go

--********************************************************************--
-- Create the Tables
--********************************************************************--
CREATE -- Customers Dimension
TABLE DimCustomers
( CustomerKey int Not Null CONSTRAINT [pkDimCustomers] PRIMARY KEY Identity(1,1)
, CustomerID int Not Null
, ContactFullName nvarchar(200) Not Null 
, CompanyName nvarchar(200) Not Null
);
go

CREATE -- Products Dimension 
TABLE DimProducts	
( ProductKey int Not Null CONSTRAINT [pkDimProducts] PRIMARY KEY Identity(1,1)
, ProductID int Not Null 
, ProductName nvarchar(50) Not Null
, ProductColor nvarchar(50) Not Null 
, ProductListPrice money Not Null  
, ProductSize nvarchar(5) Not Null
, ProductWeight decimal(8,2 ) Not Null
, ProductCategoryID int Not Null
, ProductCategoryName nVarchar(50) Not Null
);
go

CREATE -- Dates Dimension  
TABLE DimDates	
( CalendarDateKey int Not Null CONSTRAINT [pkDimDates] PRIMARY KEY
, CalendarDateName nvarchar(50) Not Null 
, CalendarYearMonthID int Not Null 
, CalendarYearMonthName nvarchar(50) Not Null 
, CalendarYearQuarterID int Not Null 
, CalendarYearQuarterName nvarchar(50) Not Null 
, CalendarYearID int Not Null 
, CalendarYearName nvarchar(50) Not Null
, CalendarDate Date Not Null  
, FiscalDate Date Not Null 
);
go

CREATE -- Primary Fact table for the Sales Data Mart
TABLE FactSales	
( SalesOrderID int
, SalesOrderDetailID int
, CustomerKey int -- FK to DimCustomers
, ProductKey int -- FK to DimProducts
, OrderDateKey int -- FK to DimDates
, ShipDateKey int -- FK to DimDates
, OrderQty smallint
, UnitPrice money
, UnitPriceDiscount money
, CONSTRAINT [pkFactSales] PRIMARY KEY 
	(
	  SalesOrderID
	, SalesOrderDetailID
	, CustomerKey
	, ProductKey
	, OrderDateKey
	)
);
go

--********************************************************************--
-- Create the Foreign Key CONSTRAINTs
--********************************************************************--
ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesToDimProducts FOREIGN KEY (ProductKey) 
	REFERENCES dbo.DimProducts	(ProductKey);
go

ALTER TABLE dbo.FactSales ADD CONSTRAINT 
	fkFactSalesToDimCustomers FOREIGN KEY (CustomerKey) 
	REFERENCES dbo.DimCustomers (CustomerKey);
go

ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesOrderDateToDimDates FOREIGN KEY (OrderDateKey) 
	REFERENCES dbo.DimDates(CalendarDateKey);
go

ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesShipDateDimDates FOREIGN KEY (ShipDateKey)
	REFERENCES dbo.DimDates (CalendarDateKey);
go


--********************************************************************--
-- Create the ETL Lookup objects
--********************************************************************--
CREATE -- Lookup Null Statuses
TABLE ETLNullStatuses	
( NullStatusID int Not Null  
, NullStatusName nvarchar (50)
, NullStatusDescription nvarchar (1000)
CONSTRAINT [pkETLNullStatuses]  PRIMARY KEY Clustered (NullStatusID desc)
);
go

--********************************************************************--
-- Fill Lookup Tables
--********************************************************************--

 -- Fill DimDates Lookup Table
	-- Step 1: Fill the table with dates data
Declare @StartDate date; 
Declare @EndDate date;

-- Get the range of years needed
Select @StartDate = '01-01-' + Cast(Year(Min([OrderDate])) as nvarchar(50))
	From [AdventureWorksLT2012].[SalesLT].[SalesOrderHeader]; 
Select @EndDate = '12-31-' + Cast(Year(Max([OrderDate]))  as nvarchar(50))
	From [AdventureWorksLT2012].[SalesLT].[SalesOrderHeader];

-- Use a while loop to add dates to the table
Declare @DateInProcess datetime = @StartDate;

While @DateInProcess <= @EndDate
	Begin
	--Add a row into the date dimension table for this date
		Insert Into [DWAdventureWorksLT2012Lab01].[dbo].[DimDates] 
		( [CalendarDateKey]
		, [CalendarDateName]
		, [CalendarYearMonthID]
		, [CalendarYearMonthName]
		, [CalendarYearQuarterID]
		, [CalendarYearQuarterName]
		, [CalendarYearID]
		, [CalendarYearName]
		, [CalendarDate]
		, [FiscalDate]
		)
		Values ( 
		Convert(nvarchar(50), @DateInProcess, 112) -- [CalendarDateKey]
		, DateName( weekday, @DateInProcess ) + ', ' + Convert(nvarchar(50), @DateInProcess, 110) --  [CalendarDateName]
		, Left(Convert(nvarchar(50), @DateInProcess, 112), 6) -- [CalendarYearMonthKey]
		, DateName( month, @DateInProcess ) -- [CalendarYearMonthName]
		, Cast( Year(@DateInProcess) as nVarchar(50)) + '0' + DateName( quarter, @DateInProcess)   --[CalendarYearQuarterKey]
		, 'Q' + DateName( quarter, @DateInProcess ) + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50)) --[CalendarYearQuarterName]
		, Year( @DateInProcess ) -- [CalendarYearKey] 
		, Cast( Year( @DateInProcess) as nVarchar(50) ) -- [CalendarYearName]
		, Convert([Date], @DateInProcess) 	-- [FiscalDateKey] 			   
		, Convert([Date], DateAdd(mm,-6,@DateInProcess)) 	-- [FiscalDateKey] 
		);  
		-- Add a day and loop again
		Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	End
go

Select 'The Lab1 database was created';
Select * From FactSales;
Select * From DimCustomers;
Select * From DimProducts;
Select * From DimDates;