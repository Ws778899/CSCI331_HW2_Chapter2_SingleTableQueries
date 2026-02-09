---------------------------------------------------------------------
-- T-SQL Fundamentals Fourth Edition
-- Chapter 02 - Single-Table Queries
-- � Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Elements of the WITH OrderValues AS
;WITH OrderValues AS
(
    SELECT
        o.OrderId,
        o.CustomerId,
        SUM(
            od.Quantity * od.UnitPrice
            * (1 - COALESCE(od.DiscountPercentage, 0) / 100.0)
        ) AS val
    FROM Sales.[Order] AS o
    JOIN Sales.[OrderDetail] AS od
        ON od.OrderId = o.OrderId
    GROUP BY o.OrderId, o.CustomerId
)
SELECT *
FROM OrderValues;
---------------------------------------------------------------------

-- Listing 2-1: Sample Query
USE Northwinds2024Student;
GO

SELECT EmployeeId, YEAR(OrderDate) AS orderyear, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING COUNT(*) > 1
ORDER BY EmployeeId, orderyear;

---------------------------------------------------------------------
-- The FROM Clause
---------------------------------------------------------------------

SELECT OrderId, CustomerId, EmployeeId, OrderDate, freight
FROM Sales.[Order];

---------------------------------------------------------------------
-- The WHERE Clause
---------------------------------------------------------------------

SELECT OrderId, EmployeeId, OrderDate, freight
FROM Sales.[Order]
WHERE CustomerId = 71;

---------------------------------------------------------------------
-- The GROUP BY Clause
---------------------------------------------------------------------

SELECT EmployeeId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate);

SELECT
  EmployeeId,
  YEAR(OrderDate) AS orderyear,
  SUM(freight) AS totalfreight,
  COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate);

/*
SELECT EmployeeId, YEAR(OrderDate) AS orderyear, freight
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate);
*/

SELECT 
  EmployeeId, 
  YEAR(OrderDate) AS orderyear, 
  COUNT(DISTINCT CustomerId) AS numcusts
FROM Sales.[Order]
GROUP BY EmployeeId, YEAR(OrderDate);

---------------------------------------------------------------------
-- The HAVING Clause
---------------------------------------------------------------------

SELECT EmployeeId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING COUNT(*) > 1;

---------------------------------------------------------------------
-- The SELECT Clause
---------------------------------------------------------------------

SELECT OrderId OrderDate
FROM Sales.[Order];

SELECT EmployeeId, YEAR(OrderDate) AS orderyear, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING COUNT(*) > 1;

/*
SELECT OrderId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE orderyear > 2021;
*/

SELECT OrderId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE YEAR(OrderDate) > 2021;

/*
SELECT EmployeeId, YEAR(OrderDate) AS orderyear, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING numorders > 1;
*/

SELECT EmployeeId, YEAR(OrderDate) AS orderyear, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING COUNT(*) > 1;

-- Listing 2-2: Query Returning Duplicate Rows
SELECT EmployeeId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE CustomerId = 71;

-- Listing 2-3: Query WITH a DISTINCT Clause
SELECT DISTINCT EmployeeId, YEAR(OrderDate) AS orderyear
FROM Sales.[Order]
WHERE CustomerId = 71;

SELECT *
FROM Sales.Shipper;

/*
SELECT OrderId,
  YEAR(OrderDate) AS orderyear,
  orderyear + 1 AS nextyear
FROM Sales.[Order];
*/

SELECT OrderId,
  YEAR(OrderDate) AS orderyear,
  YEAR(OrderDate) + 1 AS nextyear
FROM Sales.[Order];

---------------------------------------------------------------------
-- The ORDER BY Clause
---------------------------------------------------------------------

-- Listing 2-4: Query Demonstrating the ORDER BY Clause
SELECT EmployeeId, YEAR(OrderDate) AS orderyear, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE CustomerId = 71
GROUP BY EmployeeId, YEAR(OrderDate)
HAVING COUNT(*) > 1
ORDER BY EmployeeId, orderyear;

SELECT EmployeeId, EmployeeFirstName, EmployeeLastName
FROM HumanResources.Employee
ORDER BY EmployeeId;

/*
-- NOTE: Employee country column name differs in this schema; example omitted.
-- SELECT DISTINCT <EmployeeCountryColumn>
-- FROM HumanResources.Employee
ORDER BY EmployeeId;
*/

---------------------------------------------------------------------
-- The TOP and OFFSET-FETCH Filters
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The TOP Filter
---------------------------------------------------------------------

-- Listing 2-5: Query Demonstrating the TOP Option
SELECT TOP (5) OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
ORDER BY OrderDate DESC;

SELECT TOP (1) PERCENT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
ORDER BY OrderDate DESC;

-- Listing 2-6: Query Demonstrating TOP WITH Unique ORDER BY List
SELECT TOP (5) OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
ORDER BY OrderDate DESC, OrderId DESC;

SELECT TOP (5) WITH TIES OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
ORDER BY OrderDate DESC;

---------------------------------------------------------------------
-- The OFFSET-FETCH Filter
---------------------------------------------------------------------

-- OFFSET-FETCH
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
ORDER BY OrderDate, OrderId
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

---------------------------------------------------------------------
-- A Quick Look at Window Functions
---------------------------------------------------------------------

;WITH OrderValues AS
(
  SELECT
    o.OrderId,
    o.CustomerId,
    SUM(
      od.Quantity * od.UnitPrice
      * (1 - COALESCE(od.DiscountPercentage, 0) / 100.0)
    ) AS val
  FROM Sales.[Order] AS o
  JOIN Sales.[OrderDetail] AS od
    ON od.OrderId = o.OrderId
  GROUP BY o.OrderId, o.CustomerId
)
SELECT
  OrderId,
  CustomerId,
  val,
  ROW_NUMBER() OVER(
    PARTITION BY CustomerId
    ORDER BY val
  ) AS rownum
FROM OrderValues
ORDER BY CustomerId, val;

---------------------------------------------------------------------
-- Predicates and Operators
---------------------------------------------------------------------

-- Predicates: IN, BETWEEN, LIKE
;WITH OrderValues AS
(
  SELECT
    o.OrderId,
    o.CustomerId,
    SUM(
      od.Quantity * od.UnitPrice
      * (1 - COALESCE(od.DiscountPercentage, 0) / 100.0)
    ) AS val
  FROM Sales.[Order] AS o
  JOIN Sales.[OrderDetail] AS od
    ON od.OrderId = o.OrderId
  GROUP BY o.OrderId, o.CustomerId
)
SELECT OrderId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderId IN(10248, 10249, 10250);

SELECT OrderId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderId BETWEEN 10300 AND 10310;

SELECT EmployeeId, EmployeeFirstName, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'D%';

-- Comparison operators: =, >, <, >=, <=, <>, !=, !>, !< 
SELECT OrderId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate >= '20220101';

-- Logical operators: AND, OR, NOT
SELECT OrderId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate >= '20220101'
  AND EmployeeId NOT IN(1, 3, 5);

-- Arithmetic operators: +, -, *, /, %
SELECT OrderId, ProductId, Quantity, UnitPrice, DiscountPercentage,
  Quantity * UnitPrice * (1 - COALESCE(DiscountPercentage, 0) / 100.0) AS val
FROM Sales.OrderDetail;

-- Operator Precedence

-- AND precedes OR
SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE
        CustomerId = 1
    AND EmployeeId IN(1, 3, 5)
    OR  CustomerId = 85
    AND EmployeeId IN(2, 4, 6);

-- Equivalent to
SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE
      (     CustomerId = 1
        AND EmployeeId IN(1, 3, 5) )
    OR
      (     CustomerId = 85
        AND EmployeeId IN(2, 4, 6) );

-- *, / precedes +, -
SELECT 10 + 2 * 3   -- 16

SELECT (10 + 2) * 3 -- 36

---------------------------------------------------------------------
-- CASE Expression
---------------------------------------------------------------------

-- Simple
SELECT supplierid, COUNT(*) AS numproducts,
  CASE COUNT(*) % 2
    WHEN 0 THEN 'Even'
    WHEN 1 THEN 'Odd'
    ELSE 'Unknown'
  END AS countparity
FROM Production.Product
GROUP BY supplierid;

-- Searched
;WITH OrderValues AS
(
  SELECT
    o.OrderId,
    o.CustomerId,
    SUM(
      od.Quantity * od.UnitPrice
      * (1 - COALESCE(od.DiscountPercentage, 0) / 100.0)
    ) AS val
  FROM Sales.[Order] AS o
  JOIN Sales.[OrderDetail] AS od
    ON od.OrderId = o.OrderId
  GROUP BY o.OrderId, o.CustomerId
)
SELECT OrderId, CustomerId, val,
  CASE
    WHEN val < 1000.00  THEN 'Less than 1000'
    WHEN val <= 3000.00 THEN 'Between 1000 and 3000'
    WHEN val > 3000.00  THEN 'More than 3000'
    ELSE 'Unknown'
  END AS valuecategory
FROM OrderValues;

---------------------------------------------------------------------
-- NULLs
---------------------------------------------------------------------

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion = N'WA';

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion = N'WA';

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion <> N'WA';

-- Intentionally incorrect example from the book (kept as comment):
-- SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
-- FROM Sales.Customer
-- WHERE CustomerRegion = NULL;

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion IS NULL;

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion <> N'WA'
   OR CustomerRegion IS NULL;

SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customer
WHERE CustomerRegion <> N'WA' OR CustomerRegion IS NULL;

---------------------------------------------------------------------
-- The GREATEST and LEAST functions
---------------------------------------------------------------------

-- Use functions in a query against Sales.[Order]
SELECT OrderId, RequiredDate, ShipToDate,
  CASE 
    WHEN RequiredDate > ShipToDate OR ShipToDate IS NULL THEN RequiredDate
    ELSE ShipToDate
  END AS LatestDate,
  CASE 
    WHEN RequiredDate < ShipToDate OR ShipToDate IS NULL THEN RequiredDate
    ELSE ShipToDate
  END AS EarliestDate
FROM Sales.[Order]
WHERE CustomerId = 8;

-- In earlier versions of SQL Server
SELECT OrderId, RequiredDate, ShipToDate,
  CASE 
    WHEN RequiredDate > ShipToDate OR ShipToDate IS NULL THEN RequiredDate
    ELSE ShipToDate
  END AS latestdate,
  CASE 
    WHEN RequiredDate < ShipToDate OR ShipToDate IS NULL THEN RequiredDate
    ELSE ShipToDate
  END AS earliestdate
FROM Sales.[Order]
WHERE CustomerId = 8;

---------------------------------------------------------------------
-- All-At-Once Operations
---------------------------------------------------------------------

/*
SELECT 
  OrderId, 
  YEAR(OrderDate) AS orderyear, 
  orderyear + 1 AS nextyear
FROM Sales.[Order];
*/

/*
SELECT col1, col2
FROM dbo.T1
WHERE col1 <> 0 AND col2/col1 > 2;
*/

/*
SELECT col1, col2
FROM dbo.T1
WHERE
  CASE
    WHEN col1 = 0 THEN 'no' -- or 'yes' if row should be returned
    WHEN col2/col1 > 2 THEN 'yes'
    ELSE 'no'
  END = 'yes';
*/

/*
SELECT col1, col2
FROM dbo.T1
WHERE (col1 > 0 AND col2 > 2*col1) OR (col1 < 0 AND col2 < 2*col1); 
*/

---------------------------------------------------------------------
-- Working with Character Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Collation
---------------------------------------------------------------------

SELECT name, description
FROM sys.fn_helpcollations();

SELECT EmployeeId, EmployeeFirstName, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName = N'davis';

SELECT EmployeeId, EmployeeFirstName, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName COLLATE Latin1_General_CS_AS = N'davis';

---------------------------------------------------------------------
-- Operators and Functions
---------------------------------------------------------------------

-- Concatenation
SELECT EmployeeId, EmployeeFirstName + N' ' + EmployeeLastName AS fullname
FROM HumanResources.Employee;

-- Listing 2-7: Query Demonstrating String Concatenation
SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity,
  CustomerCountry + N',' + CustomerRegion + N',' + CustomerCity AS location
FROM Sales.Customer;

-- convert NULL to empty string
SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity,
  CustomerCountry + COALESCE(N',' + CustomerRegion, N'') + N',' + CustomerCity AS location
FROM Sales.Customer;

-- using the CONCAT function
SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity,
  CONCAT(CustomerCountry, N',' + CustomerRegion, N',' + CustomerCity) AS location
FROM Sales.Customer;

-- using the CONCAT function
SELECT CustomerId, CustomerCountry, CustomerRegion, CustomerCity,
  CONCAT(CustomerCountry, N',', CustomerRegion, N',', CustomerCity) AS location
FROM Sales.Customer;

-- Functions
SELECT SUBSTRING('abcde', 1, 3); -- 'abc'

SELECT RIGHT('abcde', 3); -- 'cde'

SELECT LEN(N'abcde'); -- 5

SELECT DATALENGTH(N'abcde'); -- 10

SELECT CHARINDEX(' ','Itzik Ben-Gan'); -- 6

SELECT PATINDEX('%[0-9]%', 'abcd123efgh'); -- 5

SELECT REPLACE('1-a 2-b', '-', ':'); -- '1:a 2:b'

SELECT EmployeeId, EmployeeLastName,
  LEN(EmployeeLastName) - LEN(REPLACE(EmployeeLastName, 'e', '')) AS numoccur
FROM HumanResources.Employee;

-- bug
SELECT REPLACE(REPLACE('123.456.789,00', '.', ','), ',', '.'); -- '123.456.789.00'

-- no bug
SELECT REPLACE(REPLACE(REPLACE('123.456.789,00', '.', '~'), ',', '.'), '~', ','); -- '123,456,789.00'

SELECT TRANSLATE('123.456.789,00', '.,', ',.'); -- '123,456,789.00'

SELECT REPLICATE('abc', 3); -- 'abcabcabc'

SELECT supplierid,
  RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)),
        10) AS strsupplierid
FROM Production.Supplier;

SELECT STUFF('xyz', 2, 1, 'abc'); -- 'xabcz'

SELECT UPPER('Itzik Ben-Gan'); -- 'ITZIK BEN-GAN'

SELECT LOWER('Itzik Ben-Gan'); -- 'itzik ben-gan'

SELECT RTRIM(LTRIM('   abc   ')); -- 'abc'

SELECT LTRIM(RTRIM('   abc   ')); -- 'abc'

SELECT
  TRANSLATE(TRIM(TRANSLATE(TRIM(TRANSLATE(
    '//\\ remove leading and trailing backward (\) and forward (/) slashes \\//',
    ' /', '~ ')), ' \', '^ ')), ' ^~', '\/ ')
  AS outputstring;

SELECT TRIM( '/\' 
             FROM '//\\ remove leading and trailing backward (\) and forward (/) slashes \\//' )
       AS outputstring;

SELECT FORMAT(1759, '0000000000'); -- '0000001759'

-- COMPRESS
SELECT COMPRESS(N'This is my cv. Imagine it was much longer.');

/*
INSERT INTO dbo.EmployeeCVs( EmployeeId, cv )
  VALUES( @EmployeeId, COMPRESS(@cv) );
*/

-- DECOMPRESS
SELECT DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'));

SELECT
  CAST(
    DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'))
      AS NVARCHAR(MAX));

/*
SELECT EmployeeId, CAST(DECOMPRESS(cv) AS NVARCHAR(MAX)) AS cv
FROM dbo.EmployeeCVs;
*/

-- STRING_SPLIT
SELECT CAST(value AS INT) AS myvalue
FROM STRING_SPLIT('10248,10249,10250', ',') AS S;

/*
myvalue
-----------
10248
10249
10250
*/

SELECT CAST(value AS INT) AS myvalue
FROM STRING_SPLIT('10248,10249,10250', ',') AS S;

/*
myvalue     ordinal
----------- --------
10248       1
10249       2
10250       3
*/

SELECT CustomerId,
  STUFF((
    SELECT N',' + CAST(o2.OrderId AS VARCHAR(10))
    FROM Sales.[Order] AS o2
    WHERE o2.CustomerId = o1.CustomerId
    ORDER BY o2.OrderDate DESC, o2.OrderId DESC
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, N'') AS custorders
FROM Sales.[Order] AS o1
GROUP BY CustomerId;

/*
CustomerId      custorders
----------- --------------------------------------------
1           11011,10952,10835,10702,10692,10643
2           10926,10759,10625,10308
3           10856,10682,10677,10573,10535,10507,10365
...

(89 rows affected)
*/

---------------------------------------------------------------------
-- LIKE Predicate
---------------------------------------------------------------------

-- Last name starts with D
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'D%';

-- Second character in last name is e
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'_e%';

-- First character in last name is A, B or C
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'[ABC]%';

-- First character in last name is A through E
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'[A-E]%';

-- First character in last name is not A through E
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE N'[^A-E]%';

---------------------------------------------------------------------
-- Working with Date and Time Data
---------------------------------------------------------------------

-- Literals
SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate = '20220212';

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate = CAST('20220212' AS DATE);

-- Language dependent
SET LANGUAGE British;
SELECT CAST('02/12/2022' AS DATE);

SET LANGUAGE us_english;
SELECT CAST('02/12/2022' AS DATE);

-- Language neutral
SET LANGUAGE British;
SELECT CAST('20220212' AS DATE);

SET LANGUAGE us_english;
SELECT CAST('20220212' AS DATE);

SELECT CONVERT(DATE, '02/12/2022', 101);

SELECT CONVERT(DATE, '02/12/2022', 103);

SELECT PARSE('02/12/2022' AS DATE USING 'en-US');

SELECT PARSE('02/12/2022' AS DATE USING 'en-GB');

-- Working with Date and Time Separately

-- Create Sales.[Order2] with OrderDate as DATETIME by copying data FROM Sales.[Order]
DROP TABLE IF EXISTS Sales.[Order2];

SELECT OrderId, CustomerId, EmployeeId, CAST(OrderDate AS DATETIME) AS OrderDate
INTO Sales.[Order2]
FROM Sales.[Order];

-- Query Sales.[Order2]
SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order2]
WHERE OrderDate = '20220212';

ALTER TABLE Sales.[Order2]
  ADD CONSTRAINT CHK_Orders2_orderdate
  CHECK( CONVERT(CHAR(12), OrderDate, 114) = '00:00:00:000' );

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order2]
WHERE OrderDate >= '20220212'
  AND OrderDate < '20220213';

SELECT CAST('12:30:15.123' AS DATETIME);

-- Cleanup
DROP TABLE IF EXISTS Sales.[Order2];

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE YEAR(OrderDate) = 2021;

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate >= '20210101' AND OrderDate < '20220101';

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE YEAR(OrderDate) = 2022 AND MONTH(OrderDate) = 2;

SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.[Order]
WHERE OrderDate >= '20220201' AND OrderDate < '20220301';

-- Functions

-- Current Date and Time
SELECT
  GETDATE()           AS [GETDATE],
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP],
  GETUTCDATE()        AS [GETUTCDATE],
  SYSDATETIME()       AS [SYSDATETIME],
  SYSUTCDATETIME()    AS [SYSUTCDATETIME],
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT
  CAST(SYSDATETIME() AS DATE) AS [current_date],
  CAST(SYSDATETIME() AS TIME) AS [current_time];

-- The CAST, CONVERT and PARSE Functions and their TRY_ Counterparts
SELECT CAST('20220212' AS DATE);
SELECT CAST(SYSDATETIME() AS DATE);
SELECT CAST(SYSDATETIME() AS TIME);

SELECT CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112);
SELECT CONVERT(DATETIME, CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112), 112);

SELECT CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114);
SELECT CONVERT(DATETIME, CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114), 114);

SELECT PARSE('02/12/2022' AS DATETIME USING 'en-US');
SELECT PARSE('02/12/2022' AS DATETIME USING 'en-GB');

-- SWITCHOFFSET
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00');
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+00:00');

-- TODATETIMEOFFSET
/*
UPDATE dbo.T1
  SET dto = TODATETIMEOFFSET(dt, theoffset);
*/

-- AT TIME ZONE

SELECT name, current_utc_offset, is_currently_dst
FROM sys.time_zone_info;

-- Converting non-datetimeoffset values
-- behavior similar to TODATETIMEOFFSET
SELECT
  CAST('20220212 12:00:00.0000000' AS DATETIME2)
    AT TIME ZONE 'Pacific Standard Time' AS val1,
  CAST('20220812 12:00:00.0000000' AS DATETIME2)
    AT TIME ZONE 'Pacific Standard Time' AS val2;

-- Converting datetimeoffset values
-- behavior similar to SWITCHOFFSET
SELECT
  CAST('20220212 12:00:00.0000000 -05:00' AS DATETIMEOFFSET)
    AT TIME ZONE 'Pacific Standard Time' AS val1,
  CAST('20220812 12:00:00.0000000 -04:00' AS DATETIMEOFFSET)
    AT TIME ZONE 'Pacific Standard Time' AS val2;

-- Current local time in desired time zone
SELECT SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time';

-- DATEADD
SELECT DATEADD(year, 1, '20220212');

-- DATEDIFF
SELECT DATEDIFF(day, '20210212', '20220212');

SELECT DATEDIFF_BIG(millisecond, '00010101', '20220212');

SELECT
  DATEADD(
    day, 
    DATEDIFF(day, '19000101', SYSDATETIME()), '19000101');

SELECT
  DATEADD(
    month, 
    DATEDIFF(month, '19000101', SYSDATETIME()), '19000101');

SELECT
  DATEADD(
    year, 
    DATEDIFF(year, '18991231', SYSDATETIME()), '18991231');

-- DATEPART

SELECT DATEPART(month, '20220212');

SELECT 
  DATEPART(day, '20220212') AS part_day,
  DATEPART(weekday, '20220212') AS part_weekday,
  DATEPART(dayofyear, '20220212') AS part_dayofyear;

-- DAY, MONTH, YEAR

SELECT
  DAY('20220212') AS theday,
  MONTH('20220212') AS themonth,
  YEAR('20220212') AS theyear;

-- DATENAME
SELECT DATENAME(month, '20220212');

SELECT DATENAME(year, '20220212');

-- DATEPART

SELECT DATEFROMPARTS(YEAR('20220212'), MONTH('20220212'), 1);

-- ISDATE
SELECT ISDATE('20220212');
SELECT ISDATE('20220230');

-- fromparts
SELECT
  DATEFROMPARTS(2022, 02, 12),
  DATETIME2FROMPARTS(2022, 02, 12, 13, 30, 5, 1, 7),
  DATETIMEFROMPARTS(2022, 02, 12, 13, 30, 5, 997),
  DATETIMEOFFSETFROMPARTS(2022, 02, 12, 13, 30, 5, 1, -8, 0, 7),
  SMALLDATETIMEFROMPARTS(2022, 02, 12, 13, 30),
  TIMEFROMPARTS(13, 30, 5, 1, 7);

-- EOMONTH
SELECT EOMONTH(SYSDATETIME());

-- orders placed on last day of month
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
WHERE OrderDate = EOMONTH(OrderDate);

-- without the EOMONTH function
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
WHERE OrderDate = DATEADD(month, DATEDIFF(month, '18991231', OrderDate), '18991231');

-- GENERATE_SERIES

-- Sequence of integers between 1 and 31
;WITH N AS
(
  SELECT 1 AS value
  UNION ALL
  SELECT value + 1
  FROM N
  WHERE value < 10
)
SELECT value
FROM N
OPTION (MAXRECURSION 100);

-- Sequence of all dates in 2022
DECLARE @startdate date = '20220101',
        @enddate   date = '20221231';

;WITH N AS
(
  SELECT 0 AS n
  UNION ALL
  SELECT n + 1
  FROM N
  WHERE n < DATEDIFF(day, @startdate, @enddate)
)
SELECT DATEADD(day, n, @startdate) AS dt
FROM N
OPTION (MAXRECURSION 400);

---------------------------------------------------------------------
-- Querying Metadata
---------------------------------------------------------------------

-- Catalog Views
USE Northwinds2024Student;
GO

SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables;

SELECT 
  name AS column_name,
  TYPE_NAME(system_type_id) AS column_type,
  max_length,
  collation_name,
  is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.[Order]');

-- Information Schema Views
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE';

SELECT 
  COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, 
  COLLATION_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'Sales'
  AND TABLE_NAME = N'Order';

-- System Stored Procedures and Functions
EXEC sys.sp_tables;

EXEC sys.sp_help
  @objname = N'Sales.[Order]';

EXEC sys.sp_columns
  @table_name = N'Order',
  @table_owner = N'Sales';

EXEC sys.sp_helpconstraint
  @objname = N'Sales.[Order]';

SELECT 
  SERVERPROPERTY('Collation');

SELECT
  DATABASEPROPERTYEX(N'Northwinds2024Student', 'Collation');

SELECT 
  OBJECTPROPERTY(OBJECT_ID(N'Sales.[Order]'), 'TableHasPrimaryKey');

SELECT
  COLUMNPROPERTY(OBJECT_ID(N'Sales.[Order]'), N'ShipToCountry', 'AllowsNull');

SELECT DB_NAME() AS CurrentDB;
SELECT TOP 5 * FROM Sales.Customer;
SELECT TOP 5 * FROM Sales.[Order];
  