SELECT 
    [Team11CB].[PRODUCTS].[ProductID],
    [Team11CB].[PRODUCTS].[ProductName],
    [Team11CB].[CATEGORIES].[CategoryName],
    [Team11CB].[PRODUCTS].[Description],
    [Team11CB].[PRODUCTS].[CurrentPrice],
    [Team11CB].[PRODUCTS].[Availability]
FROM [Team11CB].[PRODUCTS]
INNER JOIN [Team11CB].[CATEGORIES] 
    ON [Team11CB].[PRODUCTS].[CategoryName] = [Team11CB].[CATEGORIES].[CategoryName]
WHERE [Team11CB].[CATEGORIES].[CategoryName] = 'Tops'
  AND [Team11CB].[PRODUCTS].[ProductName] LIKE '%Sweater%';