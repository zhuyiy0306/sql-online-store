-- INFO 330 Project 1 | Team11CB | TEST 02
-- PURPOSE: Check references and possible data-quality issues.
-- SAFE: SELECT only. Nonzero issue counts should be investigated, not
-- automatically 'fixed' or deleted.
IF DB_NAME() <> 'projects'
    THROW 51002, 'STOP: Connect to projects before running this test.', 1;
GO

-- A. Relationship checks (ideally 0). These mirror the online-store design.
SELECT 'Addresses missing customer' AS CheckName, COUNT_BIG(*) AS IssueCount
FROM Team11CB.Addresses AS a
LEFT JOIN Team11CB.Customers AS c ON c.CustomerID = a.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'Products with unknown category', COUNT_BIG(*)
FROM Team11CB.Products AS p
LEFT JOIN Team11CB.Categories AS c ON c.CategoryName = p.CategoryName
WHERE p.CategoryName IS NOT NULL AND c.CategoryName IS NULL
UNION ALL
SELECT 'Orders missing customer', COUNT_BIG(*)
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.Customers AS c ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'Orders missing billing address', COUNT_BIG(*)
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.Addresses AS a
    ON a.CustomerID = o.CustomerID AND a.AddressLabel = o.BillingAddressLabel
WHERE a.CustomerID IS NULL
UNION ALL
SELECT 'Orders missing shipping address', COUNT_BIG(*)
FROM Team11CB.Orders AS o
LEFT JOIN Team11CB.Addresses AS a
    ON a.CustomerID = o.CustomerID AND a.AddressLabel = o.ShippingAddressLabel
WHERE a.CustomerID IS NULL
UNION ALL
SELECT 'OrderDetails missing order', COUNT_BIG(*)
FROM Team11CB.OrderDetails AS d
LEFT JOIN Team11CB.Orders AS o ON o.OrderID = d.OrderID
WHERE o.OrderID IS NULL
UNION ALL
SELECT 'OrderDetails missing product', COUNT_BIG(*)
FROM Team11CB.OrderDetails AS d
LEFT JOIN Team11CB.Products AS p ON p.ProductID = d.ProductID
WHERE p.ProductID IS NULL
UNION ALL
SELECT 'Wishlists missing customer', COUNT_BIG(*)
FROM Team11CB.Wishlists AS w
LEFT JOIN Team11CB.Customers AS c ON c.CustomerID = w.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'WishlistItems missing wishlist', COUNT_BIG(*)
FROM Team11CB.WishlistItems AS wi
LEFT JOIN Team11CB.Wishlists AS w ON w.WishlistID = wi.WishlistID
WHERE w.WishlistID IS NULL
UNION ALL
SELECT 'WishlistItems missing product', COUNT_BIG(*)
FROM Team11CB.WishlistItems AS wi
LEFT JOIN Team11CB.Products AS p ON p.ProductID = wi.ProductID
WHERE p.ProductID IS NULL
UNION ALL
SELECT 'Shipments missing order', COUNT_BIG(*)
FROM Team11CB.Shipments AS s
LEFT JOIN Team11CB.Orders AS o ON o.OrderID = s.OrderID
WHERE o.OrderID IS NULL
UNION ALL
SELECT 'Payments missing order', COUNT_BIG(*)
FROM Team11CB.Payments AS pa
LEFT JOIN Team11CB.Orders AS o ON o.OrderID = pa.OrderID
WHERE o.OrderID IS NULL
ORDER BY CheckName;
GO

-- B. Business-rule checks (not FK checks). Review any nonzero result.
SELECT 'Orders without any line items' AS CheckName, COUNT_BIG(*) AS IssueCount
FROM Team11CB.Orders AS o
WHERE NOT EXISTS (
    SELECT 1 FROM Team11CB.OrderDetails AS d WHERE d.OrderID = o.OrderID
)
UNION ALL
SELECT 'OrderDetails with nonpositive quantity', COUNT_BIG(*)
FROM Team11CB.OrderDetails WHERE Quantity <= 0
UNION ALL
SELECT 'OrderDetails with negative purchase price', COUNT_BIG(*)
FROM Team11CB.OrderDetails WHERE UnitPriceAtPurchase < 0
UNION ALL
SELECT 'OrderDetails with NULL purchase cost', COUNT_BIG(*)
FROM Team11CB.OrderDetails WHERE UnitCostAtPurchase IS NULL
UNION ALL
SELECT 'Products with negative current price', COUNT_BIG(*)
FROM Team11CB.Products WHERE CurrentPrice < 0
ORDER BY CheckName;
GO

-- C. Review orders where PAID payment totals differ from item totals.
-- DO NOT assume this means an error: tax, shipping, partial payments, refunds,
-- or demo-data conventions may explain differences.
WITH LineTotals AS (
    SELECT OrderID,
           SUM(CAST(Quantity * UnitPriceAtPurchase AS decimal(19,2))) AS ItemTotal
    FROM Team11CB.OrderDetails
    GROUP BY OrderID
),
PaidTotals AS (
    SELECT OrderID,
           SUM(CAST(PaymentAmount AS decimal(19,2))) AS PaidTotal
    FROM Team11CB.Payments
    WHERE PaymentStatus = 'Paid'
    GROUP BY OrderID
)
SELECT TOP (25)
    o.OrderID, o.OrderStatus,
    l.ItemTotal, p.PaidTotal,
    CAST(p.PaidTotal - l.ItemTotal AS decimal(19,2)) AS Difference
FROM Team11CB.Orders AS o
JOIN LineTotals AS l ON l.OrderID = o.OrderID
JOIN PaidTotals AS p ON p.OrderID = o.OrderID
WHERE ABS(p.PaidTotal - l.ItemTotal) > 0.01
ORDER BY o.OrderID;
GO

-- D. Date/status consistency for shipped orders (review, not automatic error).
SELECT OrderID, ShipmentStatus, ShippedDate, ActualDeliveryDate
FROM Team11CB.Shipments
WHERE ShipmentStatus IN ('Shipped', 'In Transit', 'Delivered')
  AND ShippedDate IS NULL
ORDER BY OrderID;
GO
