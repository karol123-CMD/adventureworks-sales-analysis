/*
Objetivo: explorar metadados e perfil técnico do AdventureWorks2022 OLTP.
Grão: objeto/coluna/constraint ou linha de perfil, conforme o bloco.
Universo: metadados do banco e pedidos existentes; somente leitura.
Receita/custo: não calculados neste arquivo.
Limitação: resultados dependem da instância em que o script for executado.
*/
USE AdventureWorks2022;
GO

SELECT DB_NAME() AS Banco,
       CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS VersaoProduto,
       CAST(SERVERPROPERTY('Edition') AS nvarchar(128)) AS Edicao;

SELECT name AS SchemaName
FROM sys.schemas
WHERE name IN ('Sales','Production','Person','dbo')
ORDER BY name;

WITH Objetos AS (
 SELECT SchemaName,ObjectName FROM (VALUES
  ('Sales','SalesOrderHeader'),('Sales','SalesOrderDetail'),('Sales','Customer'),
  ('Sales','Store'),('Sales','SalesTerritory'),('Production','Product'),
  ('Production','ProductSubcategory'),('Production','ProductCategory'),
  ('Production','ProductCostHistory'),('Person','Person')
 ) v(SchemaName,ObjectName)
)
SELECT s.name AS SchemaName, t.name AS TableName, c.column_id AS ColumnOrdinal,
       c.name AS ColumnName, ty.name AS DataType, c.max_length AS MaxLength,
       c.precision AS NumericPrecision, c.scale AS NumericScale, c.is_nullable AS IsNullable
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN Objetos o ON o.SchemaName=s.name AND o.ObjectName=t.name
JOIN sys.columns c ON c.object_id=t.object_id
JOIN sys.types ty ON ty.user_type_id=c.user_type_id
ORDER BY s.name,t.name,c.column_id;

WITH Objetos AS (
 SELECT SchemaName,ObjectName FROM (VALUES
  ('Sales','SalesOrderHeader'),('Sales','SalesOrderDetail'),('Sales','Customer'),
  ('Sales','Store'),('Sales','SalesTerritory'),('Production','Product'),
  ('Production','ProductSubcategory'),('Production','ProductCategory'),
  ('Production','ProductCostHistory'),('Person','Person')
 ) v(SchemaName,ObjectName)
)
SELECT s.name AS SchemaName,t.name AS TableName,kc.name AS ConstraintName,
       ic.key_ordinal AS KeyOrdinal,c.name AS KeyColumn
FROM sys.key_constraints kc
JOIN sys.tables t ON t.object_id=kc.parent_object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN Objetos o ON o.SchemaName=s.name AND o.ObjectName=t.name
JOIN sys.index_columns ic ON ic.object_id=t.object_id AND ic.index_id=kc.unique_index_id
JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE kc.type='PK'
ORDER BY s.name,t.name,ic.key_ordinal;

WITH Objetos AS (
 SELECT SchemaName,ObjectName FROM (VALUES
  ('Sales','SalesOrderHeader'),('Sales','SalesOrderDetail'),('Sales','Customer'),
  ('Sales','Store'),('Sales','SalesTerritory'),('Production','Product'),
  ('Production','ProductSubcategory'),('Production','ProductCategory'),
  ('Production','ProductCostHistory'),('Person','Person')
 ) v(SchemaName,ObjectName)
)
SELECT s1.name AS SourceSchema,t1.name AS SourceTable,c1.name AS SourceColumn,
       s2.name AS TargetSchema,t2.name AS TargetTable,c2.name AS TargetColumn,fk.name AS ForeignKeyName
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
JOIN sys.tables t1 ON t1.object_id=fkc.parent_object_id
JOIN sys.schemas s1 ON s1.schema_id=t1.schema_id
JOIN sys.columns c1 ON c1.object_id=t1.object_id AND c1.column_id=fkc.parent_column_id
JOIN sys.tables t2 ON t2.object_id=fkc.referenced_object_id
JOIN sys.schemas s2 ON s2.schema_id=t2.schema_id
JOIN sys.columns c2 ON c2.object_id=t2.object_id AND c2.column_id=fkc.referenced_column_id
WHERE EXISTS (SELECT 1 FROM Objetos o WHERE (o.SchemaName=s1.name AND o.ObjectName=t1.name) OR (o.SchemaName=s2.name AND o.ObjectName=t2.name))
ORDER BY s1.name,t1.name,c1.name;

SELECT MIN(OrderDate) AS DataMinima,MAX(OrderDate) AS DataMaxima,COUNT_BIG(*) AS QuantidadePedidos
FROM Sales.SalesOrderHeader;

SELECT Status,COUNT_BIG(*) AS QuantidadePedidos
FROM Sales.SalesOrderHeader GROUP BY Status ORDER BY Status;

SELECT s.name AS SchemaName,v.name AS ViewName,c.column_id,c.name AS ColumnName,ty.name AS DataType
FROM sys.views v
JOIN sys.schemas s ON s.schema_id=v.schema_id
JOIN sys.columns c ON c.object_id=v.object_id
JOIN sys.types ty ON ty.user_type_id=c.user_type_id
WHERE s.name='dbo' AND v.name LIKE 'vw[_]%'
ORDER BY v.name,c.column_id;
GO
