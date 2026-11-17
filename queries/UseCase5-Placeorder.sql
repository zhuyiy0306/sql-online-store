SET XACT_ABORT ON;

DECLARE @CustomerID int = 10001;
DECLARE @AddressLabel varchar(50) = 'Home';
DECLARE @ProductID int = 101;
DECLARE @OrderID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @OrderID = ISNULL(MAX(OrderID), 0) + 1
    FROM Team11CB.Orders WITH (UPDLOCK, HOLDLOCK);

    IF NOT EXISTS (
        SELECT 1
        FROM Team11CB.Addresses
        WHERE CustomerID = @CustomerID
          AND AddressLabel = @AddressLabel
    )
        THROW 50001, 'This customer does not have the saved address.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Team11CB.Products
        WHERE ProductID = @ProductID
    )
        THROW 50002, 'The product does not exist.', 1;

    INSERT INTO Team11CB.Orders
        (OrderID, CustomerID, OrderDate, OrderStatus,
         BillingAddressLabel, ShippingAddressLabel)
    VALUES
        (@OrderID, @CustomerID, GETDATE(), 'Pending',
         @AddressLabel, @AddressLabel);

    INSERT INTO Team11CB.OrderDetails
        (OrderID, ProductID, Quantity, UnitPriceAtPurchase, UnitCostAtPurchase)
    SELECT
        @OrderID, ProductID, 1, CurrentPrice, Cost
    FROM Team11CB.Products
    WHERE ProductID = @ProductID;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT OrderID, CustomerID, OrderStatus,
       BillingAddressLabel, ShippingAddressLabel
FROM Team11CB.Orders
WHERE OrderID = @OrderID;