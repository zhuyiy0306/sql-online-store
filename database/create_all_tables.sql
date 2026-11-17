
USE projects;
GO

-- 1. CUSTOMERS
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20)
);
GO

-- 2. ADDRESSES
CREATE TABLE Addresses (
    CustomerID INT NOT NULL,
    AddressLabel VARCHAR(50) NOT NULL,
    Street VARCHAR(150) NOT NULL,
    Apartment VARCHAR(50),
    City VARCHAR(80) NOT NULL,
    State VARCHAR(50),
    ZIPCode VARCHAR(15),
    Country VARCHAR(50),

    CONSTRAINT PK_Addresses
        PRIMARY KEY (CustomerID, AddressLabel),

    CONSTRAINT FK_Addresses_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO

-- 3. CATEGORIES
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY, -- 1. 它是自增的，也是主键
    CategoryName VARCHAR(100) NOT NULL UNIQUE, -- 2. 名字保持唯一，产品表依然可以引用它
    CategoryDescription VARCHAR(MAX)
);
GO

-- 4. PRODUCTS
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100),
    ProductName VARCHAR(150) NOT NULL,
    Description VARCHAR(MAX),
    CurrentPrice DECIMAL(10,2) NOT NULL,
    Cost DECIMAL(10,2),
    Availability BIT DEFAULT 1,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryName)
        REFERENCES Categories(CategoryName)
);
GO

-- 5. ORDERS
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    BillingAddressLabel VARCHAR(50) NOT NULL,
    ShippingAddressLabel VARCHAR(50) NOT NULL,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Orders_BillingAddress
        FOREIGN KEY (CustomerID, BillingAddressLabel)
        REFERENCES Addresses(CustomerID, AddressLabel),

    CONSTRAINT FK_Orders_ShippingAddress
        FOREIGN KEY (CustomerID, ShippingAddressLabel)
        REFERENCES Addresses(CustomerID, AddressLabel)
);
GO

-- 6. ORDERDETAILS
CREATE TABLE OrderDetails (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPriceAtPurchase DECIMAL(10,2) NOT NULL,
    UnitCostAtPurchase DECIMAL(10,2),

    CONSTRAINT PK_OrderDetails
        PRIMARY KEY (OrderID, ProductID),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO

-- 7. SHIPMENTS
CREATE TABLE Shipments (
    OrderID INT PRIMARY KEY,
    Carrier VARCHAR(80),
    TrackingNumber VARCHAR(100),
    ShipmentStatus VARCHAR(30),
    ShippedDate DATETIME,
    EstimatedDeliveryDate DATE,
    ActualDeliveryDate DATE,

    CONSTRAINT FK_Shipments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);
GO

-- 8. WISHLISTS
CREATE TABLE Wishlists (
    WishlistID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    WishlistName VARCHAR(100),
    CreatedDate DATETIME,

    CONSTRAINT FK_Wishlists_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO

-- 9. WISHLISTITEMS
CREATE TABLE WishlistItems (
    WishlistID INT NOT NULL,
    ProductID INT NOT NULL,
    AddedDate DATETIME,

    CONSTRAINT PK_WishlistItems
        PRIMARY KEY (WishlistID, ProductID),

    CONSTRAINT FK_WishlistItems_Wishlists
        FOREIGN KEY (WishlistID)
        REFERENCES Wishlists(WishlistID),

    CONSTRAINT FK_WishlistItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO

-- 10. PAYMENTS
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATETIME,
    PaymentMethod VARCHAR(50),
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(30),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);
GO

-- CHECK ALL TABLES
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
