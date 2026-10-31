/* Objetivo: validar contrato SQL–Power BI. Grão: coluna/chave/resumo.
Universo: views analíticas. Receita/custo: valida nomes legados. Limitação: não valida DAX ou visuais. */
USE AdventureWorks2022;
GO
SELECT v.name ViewName,c.column_id,c.name ColumnName,t.name DataType,c.max_length,c.precision,c.scale,c.is_nullable
FROM sys.views v JOIN sys.schemas s ON s.schema_id=v.schema_id JOIN sys.columns c ON c.object_id=v.object_id
JOIN sys.types t ON t.user_type_id=c.user_type_id
WHERE s.name='dbo' AND v.name IN ('vw_FactVendas','vw_DimCliente','vw_DimProduto','vw_DimTerritorio','vw_DimCalendario')
ORDER BY v.name,c.column_id;

SELECT COUNT_BIG(*) Linhas,COUNT(DISTINCT SalesOrderDetailID) ChavesDistintas,
 SUM(CASE WHEN SalesOrderDetailID IS NULL THEN 1 ELSE 0 END) ChavesNulas FROM dbo.vw_FactVendas;

SELECT SalesOrderDetailID,COUNT_BIG(*) Ocorrencias FROM dbo.vw_FactVendas GROUP BY SalesOrderDetailID HAVING COUNT_BIG(*)>1;

SELECT SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) CustomerIDNulo,
 SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) ProductIDNulo,
 SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END) OrderDateNula,
 SUM(CASE WHEN LineTotal IS NULL THEN 1 ELSE 0 END) LineTotalNulo,
 SUM(CASE WHEN CustoTotal IS NULL THEN 1 ELSE 0 END) CustoTotalNulo
FROM dbo.vw_FactVendas;
GO
