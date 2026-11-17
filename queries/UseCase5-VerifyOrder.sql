SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderStatus,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPriceAtPurchase,
    od.UnitCostAtPurchase
FROM Team11CB.Orders AS o
JOIN Team11CB.OrderDetails AS od
    ON od.OrderID = o.OrderID
JOIN Team11CB.Products AS p
    ON p.ProductID = od.ProductID
WHERE o.OrderID = 20261020002;