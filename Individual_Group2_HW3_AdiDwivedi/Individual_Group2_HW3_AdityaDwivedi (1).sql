/*Proposition 1: List customers with their delivery city
Why important: Lets businesses quickly see where each customer is located for delivery planning*/
SELECT
  c.CustomerID,
  c.CustomerName,
  ci.CityName
FROM Sales.Customers AS c
JOIN Application.Cities AS ci
  ON ci.CityID = c.DeliveryCityID
ORDER BY c.CustomerName;

/*Proposition 2: Show products that are only in catalog or only in sales 
Why important: Helps find mismatches */
SELECT
  si.StockItemID AS CatalogItem,
  il.StockItemID AS SoldItem
FROM Warehouse.StockItems AS si
FULL OUTER JOIN Sales.InvoiceLines AS il
  ON si.StockItemID = il.StockItemID
WHERE si.StockItemID IS NULL OR il.StockItemID IS NULL;

/*Proposition 3: Build all possible combinations of buying groups and cities
Why important: Useful when you want to create a matrix of all potential combinations, even if no data exists*/
SELECT
  bg.BuyingGroupName,
  ci.CityName
FROM Sales.BuyingGroups AS bg
CROSS JOIN Application.Cities AS ci
ORDER BY bg.BuyingGroupName, ci.CityName;

/*Proposition 4: Total quantity per invoice
Why important: Helps measure order sizes and demand per transaction*/
SELECT
  i.InvoiceID,
  i.InvoiceDate,
  SUM(il.Quantity) AS TotalQuantity
FROM Sales.Invoices AS i
JOIN Sales.InvoiceLines AS il
  ON il.InvoiceID = i.InvoiceID
GROUP BY i.InvoiceID, i.InvoiceDate
ORDER BY i.InvoiceDate DESC;

/*Proposition 5: Products with their supplier names
Why important: Shows where each product comes from, useful for procurement and vendor management*/
SELECT
  si.StockItemID,
  si.StockItemName,
  s.SupplierName
FROM Warehouse.StockItems AS si
JOIN Purchasing.Suppliers AS s
  ON s.SupplierID = si.SupplierID
ORDER BY si.StockItemName;


/*Proposition 6: Customers who never had an invoice
Why important: Helps sales teams identify customers who have not yet purchased*/
SELECT
  c.CustomerID,
  c.CustomerName
FROM Sales.Customers AS c
LEFT JOIN Sales.Invoices AS i
  ON i.CustomerID = c.CustomerID
WHERE i.InvoiceID IS NULL
ORDER BY c.CustomerName;



/*Proposition 7: Orders with the salesperson’s name
Why important: Allows performance tracking of salespeople by their orders*/
SELECT
  o.OrderID,
  o.OrderDate,
  p.FullName AS Salesperson
FROM Sales.Orders AS o
JOIN Application.People AS p
  ON p.PersonID = o.SalespersonPersonID
ORDER BY o.OrderDate DESC;

/*Proposition 8: Top 10 customers by number of invoices
Why important: Identifies the most frequent buyers, important for loyalty and marketing*/
SELECT TOP 10
  c.CustomerID,
  c.CustomerName,
  COUNT(*) AS InvoiceCount
FROM Sales.Invoices AS i
JOIN Sales.Customers AS c
  ON c.CustomerID = i.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY InvoiceCount DESC, c.CustomerName;

/*Proposition 9: Products and their stock groups
Why important: Lets managers see product categorization for reporting and inventory control*/
SELECT
  si.StockItemID,
  si.StockItemName,
  sg.StockGroupName
FROM Warehouse.StockItems AS si
JOIN Warehouse.StockItemStockGroups AS ssg
  ON ssg.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups AS sg
  ON sg.StockGroupID = ssg.StockGroupID
ORDER BY si.StockItemName, sg.StockGroupName;

/*Proposition 10: Orders and whether an invoice exists
Why important: Tracks which orders still need invoicing, useful for finance teams*/
SELECT
  o.OrderID,
  o.OrderDate,
  c.CustomerName,
  CASE WHEN i.InvoiceID IS NULL THEN 'No Invoice Yet' ELSE 'Invoiced' END AS InvoiceStatus
FROM Sales.Orders AS o
JOIN Sales.Customers AS c
  ON c.CustomerID = o.CustomerID
LEFT JOIN Sales.Invoices AS i
  ON i.OrderID = o.OrderID
ORDER BY o.OrderDate DESC;