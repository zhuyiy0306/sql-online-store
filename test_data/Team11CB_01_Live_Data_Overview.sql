-- INFO 330 Project 1 | Team11CB | TEST 01
-- PURPOSE: Count live rows and inspect example records WITHOUT modifying data.
-- SAFE: SELECT only. Run after test 00 confirms projects / Team11CB.
IF DB_NAME() <> 'projects'
    THROW 51001, 'STOP: Connect to projects before running this test.', 1;
GO

-- A. Current counts across all ten tables. These can change as teammates work.
SELECT 'Customers' AS TableName, COUNT_BIG(*) AS TotalRows FROM Team11CB.Customers
UNION ALL SELECT 'Addresses', COUNT_BIG(*) FROM Team11CB.Addresses
UNION ALL SELECT 'Categories', COUNT_BIG(*) FROM Team11CB.Categories
UNION ALL SELECT 'Products', COUNT_BIG(*) FROM Team11CB.Products
UNION ALL SELECT 'Orders', COUNT_BIG(*) FROM Team11CB.Orders
UNION ALL SELECT 'OrderDetails', COUNT_BIG(*) FROM Team11CB.OrderDetails
UNION ALL SELECT 'Shipments', COUNT_BIG(*) FROM Team11CB.Shipments
UNION ALL SELECT 'Wishlists', COUNT_BIG(*) FROM Team11CB.Wishlists
UNION ALL SELECT 'WishlistItems', COUNT_BIG(*) FROM Team11CB.WishlistItems
UNION ALL SELECT 'Payments', COUNT_BIG(*) FROM Team11CB.Payments;
GO

-- B. What order statuses are in the live dataset?
SELECT OrderStatus, COUNT_BIG(*) AS NumberOfOrders
FROM Team11CB.Orders
GROUP BY OrderStatus
ORDER BY NumberOfOrders DESC, OrderStatus;
GO

-- C. Sample orders with the number of products on each order.
SELECT TOP (10)
    o.OrderID, o.CustomerID, o.OrderDate, o.OrderStatus,
    COUNT(od.ProductID) AS DistinctProducts,
    COALESCE(SUM(od.Quantity), 0) AS TotalUnits
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.OrderDetails AS od ON od.OrderID = o.OrderID
GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.OrderStatus
ORDER BY o.OrderDate DESC, o.OrderID DESC;
GO

-- D. Order-date range. Useful for choosing a month for bestsellers/profit.
SELECT MIN(OrderDate) AS EarliestOrder, MAX(OrderDate) AS LatestOrder,
       COUNT_BIG(*) AS TotalOrders
FROM Team11CB.Orders;
GO

-- E. Shipment and payment status values present in the real data.
SELECT ShipmentStatus, COUNT_BIG(*) AS NumberOfShipments
FROM Team11CB.Shipments
GROUP BY ShipmentStatus
ORDER BY NumberOfShipments DESC, ShipmentStatus;
GO
SELECT PaymentStatus, COUNT_BIG(*) AS NumberOfPayments
FROM Team11CB.Payments
GROUP BY PaymentStatus
ORDER BY NumberOfPayments DESC, PaymentStatus;
GO
