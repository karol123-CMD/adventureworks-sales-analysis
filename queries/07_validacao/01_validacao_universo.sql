/* Objetivo: validar universo, período e densidade. Grão: status/mês/ano.
Universo: base completa versus padrão. Receita: após desconto. Custo: não aplicável. Limitação: somente leitura. */
USE AdventureWorks2022;
GO
SELECT h.Status,COUNT(DISTINCT h.SalesOrderID) Pedidos,COUNT_BIG(d.SalesOrderDetailID) Linhas,
 SUM(d.LineTotal) ReceitaItensAposDesconto
FROM Sales.SalesOrderHeader h LEFT JOIN Sales.SalesOrderDetail d ON d.SalesOrderID=h.SalesOrderID
GROUP BY h.Status ORDER BY h.Status;

SELECT 'Base completa' Universo,COUNT_BIG(*) Linhas,COUNT(DISTINCT d.SalesOrderID) Pedidos,SUM(d.LineTotal) Receita
FROM Sales.SalesOrderDetail d
UNION ALL
SELECT 'Universo padrão',COUNT_BIG(*),COUNT(DISTINCT d.SalesOrderID),SUM(d.LineTotal)
FROM Sales.SalesOrderDetail d JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0;

SELECT MIN(OrderDate) DataMinima,MAX(OrderDate) DataMaxima FROM dbo.vw_FactVendas;

WITH Limites AS (SELECT MIN(InicioMes) MinMes,MAX(InicioMes) MaxMes FROM dbo.vw_DimCalendario),
Meses AS (SELECT DISTINCT InicioMes FROM dbo.vw_DimCalendario),Vendas AS
(SELECT DISTINCT DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) InicioMes FROM dbo.vw_FactVendas)
SELECT m.InicioMes FROM Meses m LEFT JOIN Vendas v ON v.InicioMes=m.InicioMes WHERE v.InicioMes IS NULL ORDER BY m.InicioMes;

SELECT Ano,MAX(CONVERT(int,AnoCompleto)) AnoCompleto,MIN([Date]) DataMinima,MAX([Date]) DataMaxima
FROM dbo.vw_DimCalendario GROUP BY Ano ORDER BY Ano;
GO
