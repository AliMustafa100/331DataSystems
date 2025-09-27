USE WideWorldImporters;
GO

-- 1) Customers and their delivery city 
-- Why: quick view of where customers are located.
SELECT c.CustomerID, c.CustomerName, ci.CityName
FROM Sales.Customers c
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
ORDER BY c.CustomerName;
GO

-- 2) Top 10 products by quantity sold 
-- Why: see best-sellers by units.
SELECT TOP 10 si.StockItemID, si.StockItemName, SUM(il.Quantity) AS TotalUnits
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON si.StockItemID = il.StockItemID
GROUP BY si.StockItemID, si.StockItemName
ORDER BY TotalUnits DESC;
GO

-- 3) Orders per month (last 12 months)
-- Why: simple volume trend.
SELECT FORMAT(o.OrderDate, 'yyyy-MM') AS YearMonth,
       COUNT(*) AS OrderCount
FROM Sales.Orders o
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY YearMonth;


-- 4) Revenue by customer (top 10)
-- Why: identify top customers by sales dollars.
SELECT TOP 10 c.CustomerID, c.CustomerName, SUM(il.ExtendedPrice) AS Revenue
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c     ON c.CustomerID = i.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY Revenue DESC;
GO

-- 5) Average order value per customer
-- Why: who buys bigger orders on average.
SELECT c.CustomerID, c.CustomerName, AVG(OrderTotals.OrderValue) AS AvgOrderValue
FROM (
  SELECT o.OrderID, o.CustomerID, SUM(ol.Quantity * ol.UnitPrice) AS OrderValue
  FROM Sales.Orders o
  JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
  GROUP BY o.OrderID, o.CustomerID
) AS OrderTotals
JOIN Sales.Customers c ON c.CustomerID = OrderTotals.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY AvgOrderValue DESC;
GO

-- 6) Customers who have never been invoiced 
-- Why: leads that haven’t purchased yet.
DECLARE @cutoff date = DATEADD(DAY, -180, CAST(GETDATE() AS date));

SELECT c.CustomerID, c.CustomerName,
       MAX(i.InvoiceDate) AS LastInvoiceDate
FROM Sales.Customers c
LEFT JOIN Sales.Invoices i
  ON i.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING MAX(i.InvoiceDate) IS NULL OR MAX(i.InvoiceDate) < @cutoff
ORDER BY LastInvoiceDate;


-- 7) Orders with the salesperson’s name
-- Why: basic performance view by person.
SELECT o.OrderID, o.OrderDate, p.FullName AS Salesperson
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.SalespersonPersonID
ORDER BY o.OrderDate DESC;
GO

-- 8) Products and their stock groups 
-- Why: simple categorization lookup.
SELECT si.StockItemID, si.StockItemName, sg.StockGroupName
FROM Warehouse.StockItems si
JOIN Warehouse.StockItemStockGroups ssg ON ssg.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sg          ON sg.StockGroupID = ssg.StockGroupID
ORDER BY si.StockItemName, sg.StockGroupName;
GO

-- 9) Orders and whether an invoice exists 
-- Why: see which orders still need invoicing.
SELECT o.OrderID, o.OrderDate, c.CustomerName,
       CASE WHEN i.InvoiceID IS NULL THEN 'No Invoice Yet' ELSE 'Invoiced' END AS InvoiceStatus
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
LEFT JOIN Sales.Invoices i ON i.OrderID = o.OrderID
ORDER BY o.OrderDate DESC;
GO

-- 10) Simple city leaderboard by number of customers
-- Why: where most customers are.
SELECT ci.CityName, COUNT(*) AS CustomerCount
FROM Sales.Customers c
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
GROUP BY ci.CityName
ORDER BY CustomerCount DESC, ci.CityName;
GO
