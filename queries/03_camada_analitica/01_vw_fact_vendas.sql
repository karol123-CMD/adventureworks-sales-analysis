/* Objetivo: criar a fato analítica. Grão: SalesOrderDetailID. Universo: padrão.
Receita: itens após desconto, sem imposto/frete. Custo: histórico com fallback atual.
Limitação: LineTotal e outros aliases legados são preservados para o Power BI. */
USE AdventureWorks2022;
GO
CREATE OR ALTER VIEW dbo.vw_FactVendas AS
SELECT d.SalesOrderID,d.SalesOrderDetailID,CONVERT(date,h.OrderDate) AS OrderDate,
       CONVERT(date,h.DueDate) AS DueDate,CONVERT(date,h.ShipDate) AS ShipDate,h.Status,
       h.CustomerID,h.TerritoryID,d.ProductID,d.OrderQty,d.UnitPrice,d.UnitPriceDiscount,d.LineTotal,
       d.LineTotal AS ReceitaProdutosAposDesconto,
       hc.CustoHistorico AS CustoUnitarioHistorico,p.StandardCost AS CustoUnitarioAtual,
       cu.CustoUnitarioUtilizado,cu.FonteCusto,cu.IndicadorFallback,
       p.StandardCost AS StandardCost,ct.CustoTotal,
       CONVERT(decimal(19,4),d.LineTotal-ct.CustoTotal) AS LucroBruto,
       CONVERT(decimal(19,4),d.LineTotal-ct.CustoTotal) AS MargemBrutaEstimadaValor,
       CONVERT(decimal(19,6),(d.LineTotal-ct.CustoTotal)/NULLIF(CONVERT(decimal(19,6),d.LineTotal),0)) AS MargemBrutaEstimadaPercentual
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
JOIN Production.Product p ON p.ProductID=d.ProductID
OUTER APPLY (
 SELECT TOP (1) pch.StandardCost AS CustoHistorico
 FROM Production.ProductCostHistory pch
 WHERE pch.ProductID=d.ProductID AND h.OrderDate>=pch.StartDate
   AND (pch.EndDate IS NULL OR h.OrderDate<=pch.EndDate)
 ORDER BY pch.StartDate DESC,pch.EndDate DESC
) hc
CROSS APPLY (VALUES(
 COALESCE(hc.CustoHistorico,p.StandardCost),
 CASE WHEN hc.CustoHistorico IS NOT NULL THEN N'Histórico'
      WHEN p.StandardCost IS NOT NULL THEN N'Padrão atual (fallback)' ELSE N'Indisponível' END,
 CONVERT(bit,CASE WHEN hc.CustoHistorico IS NULL AND p.StandardCost IS NOT NULL THEN 1 ELSE 0 END)
)) cu(CustoUnitarioUtilizado,FonteCusto,IndicadorFallback)
CROSS APPLY (VALUES(CONVERT(decimal(19,4),d.OrderQty*cu.CustoUnitarioUtilizado))) ct(CustoTotal)
WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0;
GO
