SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    w.WishlistID,
    w.WishlistName,
    p.ProductID,
    p.ProductName,
    p.CurrentPrice,
    wi.AddedDate
FROM Team11CB.Customers AS c
LEFT JOIN Team11CB.Wishlists AS w
    ON w.CustomerID = c.CustomerID
LEFT JOIN Team11CB.WishlistItems AS wi
    ON wi.WishlistID = w.WishlistID
LEFT JOIN Team11CB.Products AS p
    ON p.ProductID = wi.ProductID
WHERE c.CustomerID = 10001
ORDER BY w.WishlistID, p.ProductID;

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    o.BillingAddressLabel,
    o.ShippingAddressLabel
FROM Team11CB.Orders AS o
JOIN Team11CB.Customers AS c
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID = 10001
  AND o.OrderStatus NOT IN ('Delivered', 'Cancelled')
ORDER BY o.OrderDate;
