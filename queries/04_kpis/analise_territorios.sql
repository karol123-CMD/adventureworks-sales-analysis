/* Objetivo: performance pelo território comercial do pedido e cortes por tipo de cliente.
Grão: TerritoryID. Universo: padrão. Receita: após desconto, sem imposto/frete.
Custo: não utilizado. Limitação: território nulo é exibido como Sem território. */
USE AdventureWorks2022;
GO

WITH Base AS (
 SELECT f.TerritoryID,COALESCE(t.Territorio,N'Sem território') AS Territorio,
  COALESCE(t.GrupoRegiao,N'Sem território') AS GrupoRegiao,
  SUM(f.ReceitaProdutosAposDesconto) AS Receita,COUNT(DISTINCT f.SalesOrderID) AS Pedidos,
  COUNT(DISTINCT f.CustomerID) AS Clientes
 FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimTerritorio t ON t.TerritoryID=f.TerritoryID
 GROUP BY f.TerritoryID,t.Territorio,t.GrupoRegiao
)
SELECT TerritoryID,Territorio,GrupoRegiao,Receita,Pedidos,Clientes,
 CONVERT(decimal(19,4),Receita/NULLIF(Pedidos,0)) AS TicketMedio,
 CONVERT(decimal(19,6),Receita/NULLIF(SUM(Receita) OVER(),0)) AS Participacao,
 DENSE_RANK() OVER(ORDER BY Receita DESC) AS Ranking
FROM Base ORDER BY Receita DESC,COALESCE(TerritoryID,-1);

SELECT c.TipoCliente,f.TerritoryID,COALESCE(t.Territorio,N'Sem território') AS Territorio,
 SUM(f.ReceitaProdutosAposDesconto) AS Receita,COUNT(DISTINCT f.SalesOrderID) AS Pedidos,
 COUNT(DISTINCT f.CustomerID) AS Clientes
FROM dbo.vw_FactVendas f JOIN dbo.vw_DimCliente c ON c.CustomerID=f.CustomerID
LEFT JOIN dbo.vw_DimTerritorio t ON t.TerritoryID=f.TerritoryID
GROUP BY c.TipoCliente,f.TerritoryID,t.Territorio
ORDER BY c.TipoCliente,Receita DESC,COALESCE(f.TerritoryID,-1);

-- Comparação independente por chave; uma soma global esconderia trocas entre territórios.
WITH Direta AS (
 SELECT h.TerritoryID,COUNT_BIG(*) Linhas,SUM(d.LineTotal) Receita,
  COUNT(DISTINCT h.SalesOrderID) Pedidos,COUNT(DISTINCT h.CustomerID) Clientes
 FROM Sales.SalesOrderHeader h JOIN Sales.SalesOrderDetail d ON d.SalesOrderID=h.SalesOrderID
 WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0
 GROUP BY h.TerritoryID
), Analitica AS (
 SELECT TerritoryID,COUNT_BIG(*) Linhas,SUM(ReceitaProdutosAposDesconto) Receita,
  COUNT(DISTINCT SalesOrderID) Pedidos,COUNT(DISTINCT CustomerID) Clientes
 FROM dbo.vw_FactVendas GROUP BY TerritoryID
)
SELECT COALESCE(d.TerritoryID,a.TerritoryID) TerritoryID,
 COALESCE(a.Linhas,0)-COALESCE(d.Linhas,0) DiferencaLinhas,
 COALESCE(a.Receita,0)-COALESCE(d.Receita,0) DiferencaReceita,
 COALESCE(a.Pedidos,0)-COALESCE(d.Pedidos,0) DiferencaPedidos,
 COALESCE(a.Clientes,0)-COALESCE(d.Clientes,0) DiferencaClientes,
 CASE WHEN d.Linhas IS NULL OR a.Linhas IS NULL THEN 1 ELSE 0 END GrupoAusente
FROM Direta d FULL OUTER JOIN Analitica a
 ON d.TerritoryID=a.TerritoryID OR (d.TerritoryID IS NULL AND a.TerritoryID IS NULL)
ORDER BY COALESCE(d.TerritoryID,a.TerritoryID);
GO
