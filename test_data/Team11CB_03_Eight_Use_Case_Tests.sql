-- INFO 330 Project 1 | Team11CB | TEST 03
-- PURPOSE: Read-only demonstrations of the group's EIGHT written use cases.
-- SAFE: SELECT only. This does NOT create a new order (see use case 5).
-- Some queries may correctly return zero rows if no demo data matches.
-- Uses the schema and column names from the team's shared SQL files.
IF DB_NAME() <> 'projects'
    THROW 51003, 'STOP: Connect to projects before running this test.', 1;
GO

-- USE CASE 1: Customer wishlist AND orders that are not completed.
-- Automatically choose a customer with wishlist items, if available.
DECLARE @WishlistCustomerID int = (
    SELECT TOP (1) w.CustomerID
    FROM Team11CB.Wishlists AS w
    JOIN Team11CB.WishlistItems AS wi ON wi.WishlistID = w.WishlistID
    ORDER BY w.CustomerID
);
SELECT @WishlistCustomerID AS ExampleCustomerID;
SELECT c.CustomerID, w.WishlistID, w.WishlistName,
       p.ProductID, p.ProductName, p.CurrentPrice, wi.AddedDate
FROM Team11CB.Customers AS c
JOIN Team11CB.Wishlists AS w ON w.CustomerID = c.CustomerID
JOIN Team11CB.WishlistItems AS wi ON wi.WishlistID = w.WishlistID
JOIN Team11CB.Products AS p ON p.ProductID = wi.ProductID
WHERE c.CustomerID = @WishlistCustomerID
ORDER BY p.ProductID;
SELECT o.OrderID, o.OrderDate, o.OrderStatus
FROM Team11CB.Orders AS o
WHERE o.CustomerID = @WishlistCustomerID
  AND o.OrderStatus NOT IN ('Delivered', 'Cancelled')
ORDER BY o.OrderDate DESC;
GO

-- USE CASE 2: Top ten bestselling products, October 2026.
-- Matches Query2.sql's business rule but uses Team11CB schema prefixes.
-- NOTE: Teammate Query2.sql does not filter cancelled orders; discuss
-- whether to exclude them as a business rule before final submission.
SELECT TOP (10)
       p.ProductID, p.ProductName,
       SUM(od.Quantity) AS UnitsSold
FROM Team11CB.OrderDetails AS od
JOIN Team11CB.Products AS p ON p.ProductID = od.ProductID
JOIN Team11CB.Orders AS o ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '2026-10-01'
  AND o.OrderDate < '2026-11-01'
GROUP BY p.ProductID, p.ProductName
ORDER BY UnitsSold DESC, p.ProductID;
GO

-- USE CASE 3: October 2026 gross profit using HISTORICAL purchase prices.
-- Matches the group's 3A definition: non-cancelled orders; missing cost
-- means gross profit cannot be calculated reliably and is returned as NULL.
SELECT
    COUNT_BIG(*) AS OrderDetailRows,
    COALESCE(SUM(od.Quantity * od.UnitPriceAtPurchase), 0) AS Revenue,
    CASE WHEN COUNT_BIG(*) = COUNT_BIG(od.UnitCostAtPurchase)
         THEN COALESCE(SUM(od.Quantity * od.UnitCostAtPurchase), 0)
         ELSE NULL END AS Cost,
    CASE WHEN COUNT_BIG(*) = COUNT_BIG(od.UnitCostAtPurchase)
         THEN COALESCE(SUM(od.Quantity *
                           (od.UnitPriceAtPurchase - od.UnitCostAtPurchase)), 0)
         ELSE NULL END AS GrossProfit
FROM Team11CB.Orders AS o
JOIN Team11CB.OrderDetails AS od ON od.OrderID = o.OrderID
WHERE o.OrderDate >= '2026-10-01'
  AND o.OrderDate < '2026-11-01'
  AND o.OrderStatus <> 'Cancelled';
GO

-- USE CASE 4: Search products by category + keyword.
-- Uses the same values as the team's Query4.sql ('Tops', 'Sweater').
-- Zero matching products means the filter is too narrow for this dataset,
-- not necessarily that the SQL is incorrect.
SELECT p.ProductID, p.ProductName, c.CategoryName,
       p.CurrentPrice, p.Availability
FROM Team11CB.Products AS p
JOIN Team11CB.Categories AS c ON c.CategoryName = p.CategoryName
WHERE c.CategoryName = 'Tops'
  AND p.ProductName LIKE '%Sweater%'
ORDER BY p.ProductName;
-- Backup: View all product/category combinations if the search is empty.
SELECT TOP (20) p.ProductID, p.ProductName, c.CategoryName
FROM Team11CB.Products AS p
JOIN Team11CB.Categories AS c ON c.CategoryName = p.CategoryName
ORDER BY c.CategoryName, p.ProductName;
GO

-- USE CASE 5: PRECHECK for creating an order with a saved address.
-- READ-ONLY: confirms a saved address exists and shows a linked past order.
-- This does NOT prove INSERT works. Teammate UseCase5-Placeorder.sql DOES
-- INSERT and COMMIT; only run that with explicit group approval.
SELECT TOP (10)
       c.CustomerID, a.AddressLabel, a.City, a.State
FROM Team11CB.Customers AS c
JOIN Team11CB.Addresses AS a ON a.CustomerID = c.CustomerID
ORDER BY c.CustomerID, a.AddressLabel;
SELECT TOP (10)
       o.OrderID, o.CustomerID,
       o.BillingAddressLabel, o.ShippingAddressLabel,
       a.City AS ShippingCity
FROM Team11CB.Orders AS o
JOIN Team11CB.Addresses AS a
    ON a.CustomerID = o.CustomerID
   AND a.AddressLabel = o.ShippingAddressLabel
ORDER BY o.OrderDate DESC, o.OrderID DESC;
GO

-- USE CASE 6: Show historical details for a REAL existing order.
DECLARE @HistoryOrderID bigint = (
    SELECT TOP (1) o.OrderID
    FROM Team11CB.Orders AS o
    WHERE EXISTS (SELECT 1 FROM Team11CB.OrderDetails AS od
                  WHERE od.OrderID = o.OrderID)
    ORDER BY o.OrderDate, o.OrderID
);
SELECT @HistoryOrderID AS ExampleOrderID;
SELECT o.OrderID, o.OrderDate, o.OrderStatus,
       p.ProductName, od.Quantity, od.UnitPriceAtPurchase,
       od.Quantity * od.UnitPriceAtPurchase AS ItemSubtotal
FROM Team11CB.Orders AS o
JOIN Team11CB.OrderDetails AS od ON od.OrderID = o.OrderID
JOIN Team11CB.Products AS p ON p.ProductID = od.ProductID
WHERE o.OrderID = @HistoryOrderID
ORDER BY p.ProductName;
GO

-- USE CASE 7: Orders received but not yet shipped.
-- Same rule as teammate's INFO330_UseCases_3_7_8.sql.
SELECT o.OrderID, o.CustomerID, o.OrderDate, o.OrderStatus
FROM Team11CB.Orders AS o
WHERE o.OrderStatus IN ('Pending', 'Processing')
  AND NOT EXISTS (
      SELECT 1 FROM Team11CB.Shipments AS s
      WHERE s.OrderID = o.OrderID
        AND (s.ShippedDate IS NOT NULL OR
             s.ShipmentStatus IN ('Shipped','In Transit','Delivered'))
  )
ORDER BY o.OrderDate, o.OrderID;
GO

-- USE CASE 8: Shipment status for an order we KNOW has a shipment.
DECLARE @ShipmentOrderID bigint = (
    SELECT TOP (1) s.OrderID
    FROM Team11CB.Shipments AS s
    ORDER BY s.OrderID
);
SELECT @ShipmentOrderID AS ExampleOrderID;
SELECT o.OrderID, o.OrderStatus, s.Carrier, s.TrackingNumber,
       s.ShipmentStatus, s.ShippedDate,
       s.EstimatedDeliveryDate, s.ActualDeliveryDate
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.Shipments AS s ON s.OrderID = o.OrderID
WHERE o.OrderID = @ShipmentOrderID;
GO
