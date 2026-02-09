---------------------------------------------------------------------
-- T-SQL Fundamentals Fourth Edition
-- Chapter 02 - Single-Table Queries
-- Solutions
-- � Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1 
-- Return orders placed in June 2021
-- Tables involved: TSQLV6 database, Sales.Orders table

-- Desired output:
--OrderId     OrderDate  CustomerId      EmployeeId
----------- ---------- ----------- -----------
--10555       2021-06-02 71          6
--10556       2021-06-03 73          2
--10557       2021-06-03 44          9
--10558       2021-06-04 4           1
--10559       2021-06-05 7           6
--10560       2021-06-06 25          8
--10561       2021-06-06 24          2
--10562       2021-06-09 66          1
--10563       2021-06-10 67          2
--10564       2021-06-10 65          4
--...

--(30 rows affected)

-- Solutions

-- Not recommended
SELECT
    OrderId,
    OrderDate,
    CustomerId,
    EmployeeId
FROM Sales.[Order]
WHERE YEAR(OrderDate) = 2021 AND MONTH(OrderDate) = 6;

-- Recommended
SELECT
    OrderId,
    OrderDate,
    CustomerId,
    EmployeeId
FROM Sales.[Order]
WHERE OrderDate >= '20210601' 
  AND OrderDate < '20210701';

-- 2
-- Return orders placed on the day before the last day of the month
-- Tables involved: Sales.Orders table

-- Desired output:
--OrderId     OrderDate  CustomerId      EmployeeId
----------- ---------- ----------- -----------
--10269       2020-07-31 89          5
--10317       2020-09-30 48          6
--10343       2020-10-31 44          4
--10399       2020-12-31 83          8
--10432       2021-01-31 75          3
--10460       2021-02-28 24          8
--10461       2021-02-28 46          1
--10490       2021-03-31 35          7
--10491       2021-03-31 28          8
--10522       2021-04-30 44          4
--...

--(26 rows affected)

-- Solution

-- With the EOMONTH function
SELECT
    OrderId,
    OrderDate,
    CustomerId,
    EmployeeId
FROM Sales.[Order]
WHERE OrderDate = DATEADD(day, -1, EOMONTH(OrderDate));

-- 3 
-- Return employees with last name containing the letter 'e' twice or more
-- Tables involved: HumanResources.Employee table

-- Desired output:
--EmployeeId       EmployeeFirstName  EmployeeLastName
----------- ---------- --------------------
--4           Yael       Peled
--5           Sven       Mortensen

--(2 rows affected)

-- Solution
SELECT
    EmployeeId,
    EmployeeFirstName,
    EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName LIKE '%e%e%';
-- 4 
-- Return orders with total value(qty*UnitPrice) greater than 10000
-- sorted by total value
-- Tables involved: Sales.OrderDetails table

-- Desired output:
--OrderId     totalvalue
----------- ---------------------
--10865       17250.00
--11030       16321.90
--0981       15810.00
--10372       12281.20
--10424       11493.20
--10817       11490.70
--10889       11380.00
--10417       11283.20
--10897       10835.24
--10353       10741.60
--10515       10588.50
--10479       10495.60
--10540       10191.70
--10691       10164.80

--(14 rows affected)

-- Solution
SELECT OrderId, SUM(od.Quantity*od.UnitPrice) AS totalvalue
FROM Sales.[OrderDetail] As od
GROUP BY OrderId
HAVING SUM(od.Quantity*od.UnitPrice) > 10000
ORDER BY totalvalue DESC;

-- 5
-- Write a query against the HumanResources.Employee table that returns employees
-- with a last name that starts with a lower case letter.
-- Remember that the collation of the sample database
-- is case insensitive (Latin1_General_CI_AS).
-- For simplicity, you can assume that only English letters are used
-- in the employee last names.
-- Tables involved: Sales.OrderDetails table

-- Desired output:
--EmployeeId       EmployeeLastName
----------- --------------------

--(0 rows affected)

-- Incorrect solution
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName COLLATE Latin1_General_CS_AS LIKE N'[a-z]%';

-- Correct solutions
SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

SELECT EmployeeId, EmployeeLastName
FROM HumanResources.Employee
WHERE EmployeeLastName COLLATE Latin1_General_BIN LIKE N'[a-z]%';

-- 6
-- Explain the difference between the following two queries

-- Query 1
SELECT EmployeeId, COUNT(*) AS numorders
FROM Sales.[Order]
WHERE OrderDate < '20220501'
GROUP BY EmployeeId;

-- Query 2
SELECT EmployeeId, COUNT(*) AS numorders
FROM Sales.[Order]
GROUP BY EmployeeId
HAVING MAX(OrderDate) < '20220501';

-- Answer
-- The WHERE clause is a row filter whereas the HAVING clause is a group filter.
-- Query 1 returns how many orders each employee handled prior to May 2022.
-- Query 2 returns for employees who didn�t handle any orders since May 2022 the total number of orders that they handled. 

-- 7 
-- Return the three ship countries with the highest average freight for orders placed in 2021
-- Tables involved: Sales.Orders table

-- Desired output:
--ShipToCountry     avgfreight
--------------- ---------------------
--Austria         178.3642
--Switzerland     117.1775
--Sweden          105.16

--(3 rows affected)

-- Solution
SELECT TOP (3) ShipToCountry, AVG(freight) AS avgfreight
FROM Sales.[Order]
WHERE OrderDate >= '20210101' AND OrderDate < '20220101'
GROUP BY ShipToCountry
ORDER BY avgfreight DESC;

-- With OFFSET-FETCH
SELECT ShipToCountry, AVG(freight) AS avgfreight
FROM Sales.[Order]
WHERE OrderDate >= '20210101' AND OrderDate < '20220101'
GROUP BY ShipToCountry
ORDER BY avgfreight DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- 8 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

-- Desired output:
--CustomerId      OrderDate  OrderId     rownum
----------- ---------- ----------- --------------------
--1           2021-08-25 10643       1
--1           2021-10-03 10692       2
--1           2021-10-13 10702       3
--1           2022-01-15 10835       4
--1           2022-03-16 10952       5
--1           2022-04-09 11011       6
--2           2020-09-18 10308       1
--2           2021-08-08 10625       2
--2           2021-11-28 10759       3
--2           2022-03-04 10926       4
--...

--(830 rows affected)

-- Solution
SELECT CustomerId, OrderDate, OrderId,
  ROW_NUMBER() OVER(PARTITION BY CustomerId ORDER BY OrderDate, OrderId) AS rownum
FROM Sales.[Order]
ORDER BY CustomerId, rownum;

-- 9
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HumanResources.Employee table

-- Desired output:
--EmployeeId       EmployeeFirstName  EmployeeLastName             EmployeeTitle           gender
----------- ---------- -------------------- ------------------------- -------
--1           Sara       Davis                Ms.                       Female
--2           Don        Funk                 Dr.                       Unknown
--3           Judy       Lew                  Ms.                       Female
--4           Yael       Peled                Mrs.                      Female
--5           Sven       Mortensen            Mr.                       Male
--6           Paul       Suurs                Mr.                       Male
--7           Russell    King                 Mr.                       Male
--8           Maria      Cameron              Ms.                       Female
--9           Patricia   Doyle                Ms.                       Female

--(9 rows affected)

-- Solutions
SELECT EmployeeId, EmployeeFirstName, EmployeeLastName, EmployeeTitle,
  CASE EmployeeTitle
    WHEN 'Ms.'  THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Mr.'  THEN 'Male'
    ELSE             'Unknown'
  END AS gender
FROM HumanResources.Employee;

SELECT EmployeeId, EmployeeFirstName, EmployeeLastName, EmployeeTitle,
  CASE 
    WHEN EmployeeTitle IN('Ms.', 'Mrs.') THEN 'Female'
    WHEN EmployeeTitle = 'Mr.'           THEN 'Male'
    ELSE                                        'Unknown'
  END AS gender
FROM HumanResources.Employee;

-- 10
-- Return for each customer the customer ID and region
-- sort the rows in the output by region, ascending
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULLs sort first
-- Tables involved: Sales.Customers table

-- Desired output:
--CustomerId      region
----------- ---------------
--55          AK
--10          BC
--42          BC
--45          CA
--7          Co. Cork
--33          DF
--71          ID
--38          Isle of Wight
--46          Lara
--78          MT
--...
--1           NULL
--2           NULL
--3           NULL
--4           NULL
--5           NULL
--6           NULL
--7           NULL
--8           NULL
--9           NULL
--11          NULL
--...

--(91 rows affected)

-- Solution
SELECT CustomerId, CustomerRegion
FROM Sales.Customer
ORDER BY
  CASE WHEN CustomerRegion IS NULL THEN 1 ELSE 0 END, CustomerRegion;
