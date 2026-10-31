/* Objetivo: conciliar KPIs diretos e fato. Grão: resumo único.
Universo: padrão. Receita: após desconto. Custo: disponível na fato. Limitação: diferenças devem ser investigadas. */
USE AdventureWorks2022;
GO
WITH Direta AS (
 SELECT SUM(d.LineTotal) Receita,SUM(CONVERT(bigint,d.OrderQty)) Unidades,COUNT(DISTINCT d.SalesOrderID) Pedidos,
  COUNT(DISTINCT h.CustomerID) Clientes,COUNT(DISTINCT d.ProductID) Produtos,MIN(h.OrderDate) DataMinima,MAX(h.OrderDate) DataMaxima
 FROM Sales.SalesOrderDetail d JOIN Sales.SalesOrderHeader h ON h.SalesOrderID=d.SalesOrderID
 WHERE h.Status=5 AND d.LineTotal>0 AND d.OrderQty>0
), ViewFato AS (
 SELECT SUM(ReceitaProdutosAposDesconto) Receita,SUM(CONVERT(bigint,OrderQty)) Unidades,COUNT(DISTINCT SalesOrderID) Pedidos,
  COUNT(DISTINCT CustomerID) Clientes,COUNT(DISTINCT ProductID) Produtos,SUM(CustoTotal) Custo,
  SUM(MargemBrutaEstimadaValor) Margem,MIN(OrderDate) DataMinima,MAX(OrderDate) DataMaxima FROM dbo.vw_FactVendas
)
SELECT d.Receita ReceitaDireta,v.Receita ReceitaView,v.Receita-d.Receita DiferencaReceita,
 d.Unidades UnidadesDireta,v.Unidades UnidadesView,v.Unidades-d.Unidades DiferencaUnidades,
 d.Pedidos PedidosDireta,v.Pedidos PedidosView,v.Pedidos-d.Pedidos DiferencaPedidos,
 d.Clientes ClientesDireta,v.Clientes ClientesView,v.Clientes-d.Clientes DiferencaClientes,
 d.Produtos ProdutosDireta,v.Produtos ProdutosView,v.Produtos-d.Produtos DiferencaProdutos,
 v.Custo,v.Margem,d.DataMinima DataMinimaDireta,v.DataMinima DataMinimaView,d.DataMaxima DataMaximaDireta,v.DataMaxima DataMaximaView
FROM Direta d CROSS JOIN ViewFato v;
GO
