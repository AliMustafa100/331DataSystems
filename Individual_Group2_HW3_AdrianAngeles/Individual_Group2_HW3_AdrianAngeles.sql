--Shows all Customers and their locations. Useful for parsing through customer information
SELECT c.CustomerName, ci.CityName, co.CountryName
FROM Sales.Customers AS c
INNER JOIN Application.Cities AS ci
    ON c.DeliveryCityID = ci.CityID
INNER JOIN Application.Countries AS co
    ON ci.StateProvinceID = co.CountryID
ORDER BY co.CountryName, ci.CityName;

--Lists Purchase Orders, who made them, when they were made, and when they will arrive. Helps keep track of orders made.

SELECT po.PurchaseOrderID, s.SupplierName, po.OrderDate, po.ExpectedDeliveryDate
FROM Purchasing.PurchaseOrders AS po
INNER JOIN Purchasing.Suppliers AS s
    ON po.SupplierID = s.SupplierID
ORDER BY po.OrderDate DESC;

-- Shows invoice ID, the Stock Item's name, Quantity of units sold, Price per unit, and Total Revenue. Useful for documenting profit margins and demand

SELECT il.InvoiceID, si.StockItemName, il.Quantity, il.UnitPrice, (il.Quantity * il.UnitPrice) AS LineTotal
FROM Sales.InvoiceLines AS il
INNER JOIN Warehouse.StockItems AS si
    ON il.StockItemID = si.StockItemID
ORDER BY il.InvoiceID;

--Shows every supplier and what item they sell. Useful for sorting supplier's by their stock for categorization

SELECT s.SupplierName, si.StockItemName
FROM Warehouse.StockItems AS si
RIGHT JOIN Purchasing.Suppliers AS s
    ON si.SupplierID = s.SupplierID
ORDER BY s.SupplierName;

-- Shows every invoice made by customers from most recent to least recent. Can help traversing through invoices

SELECT i.InvoiceID, i.InvoiceDate, c.CustomerName
FROM Sales.Invoices AS i
LEFT JOIN Sales.Customers AS c
    ON i.CustomerID = c.CustomerID
ORDER BY i.InvoiceDate DESC;

--Show's the top 10 customers with the highest spending rate. Useful for finding biggest profit sources

SELECT TOP 10 c.CustomerName,
       SUM(il.Quantity * il.UnitPrice) AS TotalSpent
FROM Sales.Customers AS c
INNER JOIN Sales.Invoices AS i
    ON c.CustomerID = i.CustomerID
INNER JOIN Sales.InvoiceLines AS il
    ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC;

--Catgorizes items sold by their ColorIds. Helps make sorting sales easier and helps find sales patterns

SELECT si.ColorID, SUM(il.Quantity) AS TotalSold
FROM Sales.InvoiceLines AS il
INNER JOIN Warehouse.StockItems AS si
    ON il.StockItemID = si.StockItemID
GROUP BY si.ColorID
ORDER BY TotalSold DESC;

--Displays the Total revenue from each supplier. Useful for helping track which suppliers are profitable and which are a detriment

SELECT s.SupplierName, SUM(il.Quantity * il.UnitPrice) AS SupplierRevenue
FROM Purchasing.Suppliers AS s
INNER JOIN Warehouse.StockItems AS si
    ON s.SupplierID = si.SupplierID
INNER JOIN Sales.InvoiceLines AS il
    ON si.StockItemID = il.StockItemID
GROUP BY s.SupplierName
ORDER BY SupplierRevenue DESC;

--Shows total sales value per city. Helps track high earning reigions

SELECT
  ci.CityName,
  SUM(il.ExtendedPrice) AS TotalSales
FROM Application.Cities AS ci
JOIN Sales.Customers     AS c  ON c.DeliveryCityID = ci.CityID
JOIN Sales.Invoices      AS i  ON i.CustomerID = c.CustomerID
JOIN Sales.InvoiceLines  AS il ON il.InvoiceID = i.InvoiceID
GROUP BY ci.CityName
ORDER BY TotalSales DESC;

-- Shows Highest ranking Stock items by how much they sold. Tracks are the highest ranking items by themselves

SELECT TOP 10
       si.StockItemName,
       SUM(il.LineProfit) AS TotalProfit
FROM Sales.InvoiceLines AS il
JOIN Warehouse.StockItems AS si
    ON il.StockItemID = si.StockItemID
GROUP BY si.StockItemName
ORDER BY TotalProfit DESC;
