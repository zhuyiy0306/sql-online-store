-- INFO 330 Team Database | projects | Team11CB
-- Read-only queries. Run each section separately, or run the whole file.
-- Column names were checked against the live database on 2026-11-15.

-- ============================================================
-- 3A. Monthly Gross Profit
-- Change @Year and @Month to choose a month.
-- Gross profit = SUM(Quantity * (purchase price - purchase cost)).
-- This report uses OrderDate and includes all non-cancelled orders.
-- It is an order-based report, rather than a report of cash received.
-- If a line has no recorded cost, TotalCost/GrossProfit return NULL.
-- ============================================================
DECLARE @Year int = 2026;
DECLARE @Month int = 10;
DECLARE @StartDate date = DATEFROMPARTS(@Year, @Month, 1);

SELECT
    @Year AS SalesYear,
    @Month AS SalesMonth,
    COALESCE(SUM(od.Quantity * od.UnitPriceAtPurchase), 0) AS TotalRevenue,
    CASE WHEN COUNT(*) = COUNT(od.UnitCostAtPurchase)
        THEN COALESCE(SUM(od.Quantity * od.UnitCostAtPurchase), 0)
    END AS TotalCost,
    CASE WHEN COUNT(*) = COUNT(od.UnitCostAtPurchase)
        THEN COALESCE(SUM(od.Quantity *
            (od.UnitPriceAtPurchase - od.UnitCostAtPurchase)), 0)
    END AS GrossProfit
FROM Team11CB.Orders AS o
JOIN Team11CB.OrderDetails AS od
    ON o.OrderID = od.OrderID
WHERE o.OrderDate >= @StartDate
  AND o.OrderDate < DATEADD(month, 1, @StartDate)
  AND o.OrderStatus <> 'Cancelled';
GO

-- ============================================================
-- 3B. Yearly Gross Profit
-- Change @Year to choose a year. Uses the same definition as 3A.
-- ============================================================
DECLARE @Year int = 2026;
DECLARE @StartDate date = DATEFROMPARTS(@Year, 1, 1);

SELECT
    @Year AS SalesYear,
    COALESCE(SUM(od.Quantity * od.UnitPriceAtPurchase), 0) AS TotalRevenue,
    CASE WHEN COUNT(*) = COUNT(od.UnitCostAtPurchase)
        THEN COALESCE(SUM(od.Quantity * od.UnitCostAtPurchase), 0)
    END AS TotalCost,
    CASE WHEN COUNT(*) = COUNT(od.UnitCostAtPurchase)
        THEN COALESCE(SUM(od.Quantity *
            (od.UnitPriceAtPurchase - od.UnitCostAtPurchase)), 0)
    END AS GrossProfit
FROM Team11CB.Orders AS o
JOIN Team11CB.OrderDetails AS od
    ON o.OrderID = od.OrderID
WHERE o.OrderDate >= @StartDate
  AND o.OrderDate < DATEADD(year, 1, @StartDate)
  AND o.OrderStatus <> 'Cancelled';
GO

-- ============================================================
-- 7. Find Received but Not Shipped Orders
-- "Received" means the store has received the order, not that the
-- customer has received the package. Pending/Processing orders qualify.
-- Includes orders with no shipment row or only unshipped shipment rows.
-- An order with any dispatched shipment is excluded.
-- ============================================================
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.OrderStatus
FROM Team11CB.Orders AS o
WHERE o.OrderStatus IN ('Pending', 'Processing')
  AND NOT EXISTS (
      SELECT 1
      FROM Team11CB.Shipments AS s
      WHERE s.OrderID = o.OrderID
        AND (
            s.ShippedDate IS NOT NULL
            OR s.ShipmentStatus IN ('Shipped', 'In Transit', 'Delivered')
        )
  )
ORDER BY o.OrderDate, o.OrderID;
GO

-- ============================================================
-- 8. Check Shipment Status for an Order
-- OrderID is bigint because it uses the date + sequence format.
-- Change @OrderID to an existing order you want to look up.
-- LEFT JOIN also shows the order when no shipment row exists.
-- ============================================================
DECLARE @OrderID bigint = 20261013001;

SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderStatus,
    s.Carrier,
    s.TrackingNumber,
    COALESCE(s.ShipmentStatus, 'No Shipment Record') AS ShipmentStatus,
    s.ShippedDate,
    s.EstimatedDeliveryDate,
    s.ActualDeliveryDate
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.Shipments AS s
    ON o.OrderID = s.OrderID
WHERE o.OrderID = @OrderID
ORDER BY s.ShippedDate, s.TrackingNumber;
GO
