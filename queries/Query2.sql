SELECT TOP 10
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalSold
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
JOIN Orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderDate >= '2026-10-01'
  AND o.OrderDate < '2026-11-01'
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSold DESC;