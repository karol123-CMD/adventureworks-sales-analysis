/* Objetivo: segmentação RFM e Pareto de clientes pessoa, loja ou não identificado.
Grão: CustomerID. Universo: padrão. Receita: após desconto, sem imposto/frete.
Custo: não utilizado. Limitação: escores RFM são descritivos e não implicam ação comercial. */
USE AdventureWorks2022;
GO

WITH Ref AS (SELECT MAX(OrderDate) DataReferencia FROM dbo.vw_FactVendas),
Base AS (
 SELECT f.CustomerID,MAX(c.NomeCliente) NomeCliente,MAX(c.TipoCliente) TipoCliente,
  DATEDIFF(day,MAX(f.OrderDate),MAX(r.DataReferencia)) RecenciaDias,
  COUNT(DISTINCT f.SalesOrderID) FrequenciaPedidos,SUM(f.ReceitaProdutosAposDesconto) ValorMonetario
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimCliente c ON c.CustomerID=f.CustomerID CROSS JOIN Ref r GROUP BY f.CustomerID
), Rfm AS (
 SELECT *,NTILE(5) OVER(ORDER BY RecenciaDias DESC,CustomerID) EscoreRecencia,
  NTILE(5) OVER(ORDER BY FrequenciaPedidos,CustomerID) EscoreFrequencia,
  NTILE(5) OVER(ORDER BY ValorMonetario,CustomerID) EscoreMonetario
 FROM Base
)
SELECT CustomerID,NomeCliente,TipoCliente,RecenciaDias,FrequenciaPedidos,ValorMonetario,
 EscoreRecencia,EscoreFrequencia,EscoreMonetario,
 CONCAT(EscoreRecencia,EscoreFrequencia,EscoreMonetario) AS CodigoRFM
FROM Rfm ORDER BY EscoreMonetario DESC,EscoreFrequencia DESC,EscoreRecencia DESC,CustomerID;

WITH Base AS (
 SELECT f.CustomerID,MAX(c.NomeCliente) NomeCliente,MAX(c.TipoCliente) TipoCliente,
  SUM(f.ReceitaProdutosAposDesconto) Receita
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimCliente c ON c.CustomerID=f.CustomerID GROUP BY f.CustomerID
), O AS (
 SELECT *,ROW_NUMBER() OVER(ORDER BY Receita DESC,CustomerID) Posicao,COUNT(*) OVER() TotalClientes,
  SUM(Receita) OVER() ReceitaTotal,
  SUM(Receita) OVER(ORDER BY Receita DESC,CustomerID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ReceitaAcumulada
 FROM Base
), P AS (
 SELECT *,CONVERT(decimal(19,6),ReceitaAcumulada/NULLIF(ReceitaTotal,0)) PercentualReceitaAcumulada,
  CONVERT(decimal(19,6),Posicao*1.0/NULLIF(TotalClientes,0)) PercentualClientesAcumulado FROM O
)
SELECT CustomerID,NomeCliente,TipoCliente,Receita,Posicao,TotalClientes,
 PercentualReceitaAcumulada,PercentualClientesAcumulado
FROM P ORDER BY Posicao;

WITH B AS (SELECT CustomerID,SUM(ReceitaProdutosAposDesconto) Receita FROM dbo.vw_FactVendas GROUP BY CustomerID),
O AS (SELECT *,ROW_NUMBER() OVER(ORDER BY Receita DESC,CustomerID) Posicao,COUNT(*) OVER() Total,
 SUM(Receita) OVER() TotalReceita,SUM(Receita) OVER(ORDER BY Receita DESC,CustomerID ROWS UNBOUNDED PRECEDING) Acumulada FROM B),
L AS (SELECT MIN(Posicao) QuantidadePara80,MAX(Total) TotalClientes FROM O WHERE Acumulada>=TotalReceita*0.80)
SELECT QuantidadePara80,TotalClientes,CONVERT(decimal(19,6),QuantidadePara80*1.0/NULLIF(TotalClientes,0)) PercentualClientesPara80 FROM L;
GO
