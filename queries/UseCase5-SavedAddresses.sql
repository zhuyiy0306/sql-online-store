SELECT
    CustomerID,
    AddressLabel,
    Street,
    Apartment,
    City,
    State,
    ZIPCode,
    Country
FROM Team11CB.Addresses
WHERE CustomerID = 10001
ORDER BY AddressLabel;