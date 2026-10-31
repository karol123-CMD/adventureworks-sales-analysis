/*
Objetivo: diagnosticar integridade, coerência e cobertura sem alterar dados.
Grão: linha de venda, pedido ou entidade, conforme o bloco.
Universo: base completa para diagnóstico; o universo padrão é identificado separadamente.
Receita: LineTotal = itens após desconto, sem impostos e frete.
Custo: histórico por intervalo; fallback não é aplicado neste diagnóstico.
Limitação: repetição de produto no pedido não é tratada como duplicata automática.
*/
USE AdventureWorks2022;
GO

-- Unicidade da chave técnica usada pelo modelo.
SELECT SalesOrderDetailID,COUNT_BIG(*) AS Ocorrencias
FROM Sales.SalesOrderDetail GROUP BY SalesOrderDetailID HAVING COUNT_BIG(*)>1;

-- Linhas potencialmente idênticas sem considerar a chave técnica; apenas investigação.
SELECT SalesOrderID,ProductID,OrderQty,UnitPrice,UnitPriceDiscount,LineTotal,COUNT_BIG(*) AS Ocorrencias
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID,ProductID,OrderQty,UnitPrice,UnitPriceDiscount,LineTotal
HAVING COUNT_BIG(*)>1;

-- Órfãos nas relações usadas pela camada analítica.
SELECT 'Detail_Header' AS Teste,COUNT_BIG(*) AS Quantidade
FROM Sales.SalesOrderDetail d LEFT JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID WHERE h.SalesOrderID IS NULL
UNION ALL SELECT 'Detail_Product',COUNT_BIG(*) FROM Sales.SalesOrderDetail d LEFT JOIN Production.Product p ON p.ProductID=d.ProductID WHERE p.ProductID IS NULL
UNION ALL SELECT 'Header_Customer',COUNT_BIG(*) FROM Sales.SalesOrderHeader h LEFT JOIN Sales.Customer c ON c.CustomerID=h.CustomerID WHERE c.CustomerID IS NULL;

SELECT
 COUNT(DISTINCT CASE WHEN h.TerritoryID IS NULL THEN h.SalesOrderID END) AS PedidosSemTerritorio,
 COUNT(DISTINCT CASE WHEN c.PersonID IS NULL AND c.StoreID IS NULL THEN h.SalesOrderID END) AS PedidosClienteNaoIdentificado,
 SUM(CASE WHEN p.ProductSubcategoryID IS NULL THEN 1 ELSE 0 END) AS LinhasProdutoSemSubcategoria,
 SUM(CASE WHEN p.ProductSubcategoryID IS NOT NULL AND pc.ProductCategoryID IS NULL THEN 1 ELSE 0 END) AS LinhasProdutoSemCategoria
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
LEFT JOIN Sales.Customer c ON c.CustomerID=h.CustomerID
LEFT JOIN Production.Product p ON p.ProductID=d.ProductID
LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID=p.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID=ps.ProductCategoryID;

SELECT
 SUM(CASE WHEN LineTotal<=0 THEN 1 ELSE 0 END) AS LinhasLineTotalNaoPositivo,
 SUM(CASE WHEN OrderQty<=0 THEN 1 ELSE 0 END) AS LinhasQuantidadeNaoPositiva,
 SUM(CASE WHEN UnitPriceDiscount<0 OR UnitPriceDiscount>1 THEN 1 ELSE 0 END) AS DescontosForaIntervalo
FROM Sales.SalesOrderDetail;

SELECT
 SUM(CASE WHEN OrderDate>DueDate THEN 1 ELSE 0 END) AS PedidoAposVencimento,
 SUM(CASE WHEN ShipDate<OrderDate THEN 1 ELSE 0 END) AS EnvioAntesPedido,
 SUM(CASE WHEN Status=5 AND ShipDate IS NULL THEN 1 ELSE 0 END) AS EnviadoSemDataEnvio,
 SUM(CASE WHEN Status<>5 AND ShipDate IS NOT NULL THEN 1 ELSE 0 END) AS NaoEnviadoComDataEnvio
FROM Sales.SalesOrderHeader;

WITH Detalhe AS (
 SELECT SalesOrderID,CONVERT(decimal(19,4),SUM(LineTotal)) AS SomaDetalhes
 FROM Sales.SalesOrderDetail GROUP BY SalesOrderID
)
SELECT h.SalesOrderID,d.SomaDetalhes,CONVERT(decimal(19,4),h.SubTotal) AS SubTotal,
       CONVERT(decimal(19,4),d.SomaDetalhes-h.SubTotal) AS Diferenca
FROM Sales.SalesOrderHeader h JOIN Detalhe d ON d.SalesOrderID=h.SalesOrderID
WHERE ABS(d.SomaDetalhes-h.SubTotal)>0.01
ORDER BY ABS(d.SomaDetalhes-h.SubTotal) DESC,h.SalesOrderID;

SELECT SalesOrderID,SubTotal,TaxAmt,Freight,TotalDue,
       CONVERT(decimal(19,4),TotalDue-(SubTotal+TaxAmt+Freight)) AS Diferenca
FROM Sales.SalesOrderHeader
WHERE ABS(TotalDue-(SubTotal+TaxAmt+Freight))>0.01
ORDER BY ABS(TotalDue-(SubTotal+TaxAmt+Freight)) DESC,SalesOrderID;

WITH Matches AS (
 SELECT d.SalesOrderDetailID,COUNT(pch.ProductID) AS CustosCorrespondentes
 FROM Sales.SalesOrderDetail d JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
 LEFT JOIN Production.ProductCostHistory pch ON pch.ProductID=d.ProductID
  AND h.OrderDate>=pch.StartDate AND (pch.EndDate IS NULL OR h.OrderDate<=pch.EndDate)
 WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0
 GROUP BY d.SalesOrderDetailID
)
SELECT CustosCorrespondentes,COUNT_BIG(*) AS LinhasVenda
FROM Matches GROUP BY CustosCorrespondentes ORDER BY CustosCorrespondentes;
GO
