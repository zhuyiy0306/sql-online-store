-- Find a customer's orders
CREATE INDEX IX_Orders_CustomerID
ON Team11CB.Orders (CustomerID);
GO

-- Find orders within a date range
CREATE INDEX IX_Orders_OrderDate
ON Team11CB.Orders (OrderDate);
GO

-- Find products by category
CREATE INDEX IX_Products_CategoryName
ON Team11CB.Products (CategoryName);
GO