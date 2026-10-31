/* Objetivo: validar custo histórico e fallback. Grão: linha de venda/fonte.
Universo: padrão. Receita: após desconto. Custo: intervalo histórico com fallback atual. Convenção: datas de vigência inclusivas; a base usa datas à meia-noite. */
USE AdventureWorks2022;
GO
WITH M AS (
 SELECT d.SalesOrderDetailID,COUNT(pch.ProductID) Matches
 FROM Sales.SalesOrderDetail d JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
 LEFT JOIN Production.ProductCostHistory pch ON pch.ProductID=d.ProductID AND h.OrderDate>=pch.StartDate
  AND (pch.EndDate IS NULL OR h.OrderDate<=pch.EndDate)
 WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0 GROUP BY d.SalesOrderDetailID
)
SELECT Matches,COUNT_BIG(*) Linhas FROM M GROUP BY Matches ORDER BY Matches;

SELECT FonteCusto,IndicadorFallback,COUNT_BIG(*) Linhas,
 SUM(ReceitaProdutosAposDesconto) Receita,SUM(CustoTotal) CustoEstimado
FROM dbo.vw_FactVendas GROUP BY FonteCusto,IndicadorFallback ORDER BY FonteCusto;

SELECT SUM(CASE WHEN IndicadorFallback=1 THEN CustoTotal ELSE 0 END) CustoAfetadoFallback,
 SUM(CASE WHEN IndicadorFallback=1 THEN ReceitaProdutosAposDesconto ELSE 0 END) ReceitaAfetadaFallback
FROM dbo.vw_FactVendas;

-- Deve retornar zero: contrato de datas diárias e intervalos inclusivos.
SELECT COUNT_BIG(*) IntervalosInvalidos
FROM Production.ProductCostHistory WHERE EndDate<StartDate;

SELECT COUNT_BIG(*) SobreposicoesInclusivas
FROM Production.ProductCostHistory a JOIN Production.ProductCostHistory b
 ON a.ProductID=b.ProductID AND a.StartDate<b.StartDate
 AND (a.EndDate IS NULL OR b.StartDate<=a.EndDate);

SELECT COUNT_BIG(*) DatasCustoComHorario
FROM Production.ProductCostHistory
WHERE CONVERT(time,StartDate)<>'00:00:00' OR CONVERT(time,EndDate)<>'00:00:00';
SELECT COUNT_BIG(*) PedidosComHorario
FROM Sales.SalesOrderHeader WHERE CONVERT(time,OrderDate)<>'00:00:00';

-- Custo histórico recuperado no último dia (inclusivo) da vigência.
SELECT COUNT_BIG(*) LinhasNaFronteira,SUM(f.CustoTotal) CustoHistoricoFronteira,
 SUM(CONVERT(decimal(19,4),f.OrderQty*f.CustoUnitarioAtual)-f.CustoTotal) ReducaoVsFallbackAtual
FROM dbo.vw_FactVendas f
WHERE EXISTS (SELECT 1 FROM Production.ProductCostHistory c
 WHERE c.ProductID=f.ProductID AND c.EndDate=f.OrderDate)
 AND f.IndicadorFallback=0;
GO
