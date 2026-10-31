/*
Objetivo: referência dos KPIs financeiros.
Grão: total do universo padrão; cabeçalho agregado separadamente.
Universo: Status=5, LineTotal>0 e OrderQty>0, materializado em vw_FactVendas.
Receita: itens após desconto, sem impostos e frete.
Custo: histórico vigente na data; StandardCost atual como fallback explícito.
Limitação: margem é estimada; intervalo final de custo requer validação em execução.
*/
USE AdventureWorks2022;
GO

SELECT CONVERT(decimal(19,4),SUM(ReceitaProdutosAposDesconto)) AS ReceitaProdutosAposDesconto,
       SUM(OrderQty) AS UnidadesVendidas,COUNT(DISTINCT SalesOrderID) AS Pedidos,
       CONVERT(decimal(19,4),SUM(ReceitaProdutosAposDesconto)/NULLIF(COUNT(DISTINCT SalesOrderID),0)) AS TicketMedio,
       CONVERT(decimal(19,4),SUM(CustoTotal)) AS CustoTotalEstimado,
       CONVERT(decimal(19,4),SUM(MargemBrutaEstimadaValor)) AS MargemBrutaEstimadaValor,
       CONVERT(decimal(19,6),SUM(MargemBrutaEstimadaValor)/NULLIF(SUM(ReceitaProdutosAposDesconto),0)) AS MargemBrutaEstimadaPercentual,
       SUM(CONVERT(bigint,IndicadorFallback)) AS LinhasComFallback,
       CONVERT(decimal(19,6),SUM(CONVERT(decimal(19,6),IndicadorFallback))/NULLIF(COUNT_BIG(*),0)) AS PercentualLinhasComFallback
FROM dbo.vw_FactVendas;

SELECT CONVERT(decimal(19,4),SUM(h.TaxAmt)) AS Impostos,
       CONVERT(decimal(19,4),SUM(h.Freight)) AS Frete,
       CONVERT(decimal(19,4),SUM(h.TotalDue)) AS ValorTotalDevido
FROM Sales.SalesOrderHeader h
WHERE h.Status=5 AND EXISTS (SELECT 1 FROM Sales.SalesOrderDetail d WHERE d.SalesOrderID=h.SalesOrderID AND d.LineTotal>0 AND d.OrderQty>0);

SELECT FonteCusto,COUNT_BIG(*) AS Linhas,
       CONVERT(decimal(19,4),SUM(ReceitaProdutosAposDesconto)) AS ReceitaProdutosAposDesconto,
       CONVERT(decimal(19,4),SUM(CustoTotal)) AS CustoTotalEstimado
FROM dbo.vw_FactVendas GROUP BY FonteCusto ORDER BY FonteCusto;
GO
