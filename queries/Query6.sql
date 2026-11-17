SELECT 
    [Team11CB].[ORDERS].[OrderID],
    [Team11CB].[ORDERS].[OrderDate],
    [Team11CB].[PRODUCTS].[ProductName],
    [Team11CB].[ORDERDETAILS].[Quantity],
    [Team11CB].[ORDERDETAILS].[UnitPriceAtPurchase],
    ([Team11CB].[ORDERDETAILS].[Quantity] * [Team11CB].[ORDERDETAILS].[UnitPriceAtPurchase]) AS [ItemSubTotal]
FROM [Team11CB].[ORDERS]
INNER JOIN [Team11CB].[ORDERDETAILS] 
    ON [Team11CB].[ORDERS].[OrderID] = [Team11CB].[ORDERDETAILS].[OrderID]
INNER JOIN [Team11CB].[PRODUCTS] 
    ON [Team11CB].[ORDERDETAILS].[ProductID] = [Team11CB].[PRODUCTS].[ProductID]
WHERE [Team11CB].[ORDERS].[OrderID] = 20261001001;