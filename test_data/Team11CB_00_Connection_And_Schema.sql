-- INFO 330 Project 1 | Team11CB | TEST 00
-- PURPOSE: Confirm the connection, 10 tables, and actual column definitions.
-- SAFE: Read-only metadata queries. Run this file FIRST.
-- EXPECTED database = projects; schema = Team11CB.

SELECT DB_NAME() AS CurrentDatabase,
       @@SERVERNAME AS ServerName,
       SCHEMA_ID('Team11CB') AS TeamSchemaID;
GO

-- Confirm the ten expected tables are visible to your login.
SELECT expected.TableName,
       CASE WHEN t.object_id IS NULL THEN 'MISSING / NOT VISIBLE'
            ELSE 'FOUND' END AS TableStatus
FROM (VALUES ('Customers'), ('Addresses'), ('Categories'), ('Products'),
             ('Orders'), ('OrderDetails'), ('Shipments'), ('Wishlists'),
             ('WishlistItems'), ('Payments')) AS expected(TableName)
LEFT JOIN sys.tables AS t
    ON t.name = expected.TableName
   AND t.schema_id = SCHEMA_ID('Team11CB')
ORDER BY expected.TableName;
GO

-- IMPORTANT: The older create_all_tables.sql was an early draft and may
-- differ from the existing live tables. This is the live column truth.
SELECT t.name AS TableName,
       c.column_id AS ColumnOrder,
       c.name AS ColumnName,
       ty.name AS DataType,
       c.max_length AS MaxLengthBytes,
       c.precision AS NumericPrecision,
       c.scale AS NumericScale,
       c.is_nullable AS AllowsNull,
       c.is_identity AS IsIdentity
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
JOIN sys.columns AS c ON c.object_id = t.object_id
JOIN sys.types AS ty ON ty.user_type_id = c.user_type_id
WHERE s.name = 'Team11CB'
ORDER BY t.name, c.column_id;
GO
