/* Objetivo: estatística descritiva em grãos explicitamente separados.
Universo: padrão. Receita: após desconto, sem imposto/frete. Custo: não utilizado.
Regra: população completa disponível, portanto STDEVP/VARP. Limitação: resultados são descritivos. */
USE AdventureWorks2022;
GO

-- Grão: linha de venda.
SELECT COUNT_BIG(*) N,AVG(CONVERT(float,ReceitaProdutosAposDesconto)) MediaReceitaLinha,
 MIN(ReceitaProdutosAposDesconto) MinimoReceitaLinha,MAX(ReceitaProdutosAposDesconto) MaximoReceitaLinha,
 STDEVP(CONVERT(float,ReceitaProdutosAposDesconto)) DesvioPadraoPopulacional,
 VARP(CONVERT(float,ReceitaProdutosAposDesconto)) VarianciaPopulacional
FROM dbo.vw_FactVendas;

-- Grão: pedido.
WITH P AS (SELECT SalesOrderID,SUM(ReceitaProdutosAposDesconto) Receita FROM dbo.vw_FactVendas GROUP BY SalesOrderID)
SELECT COUNT(*) N,AVG(CONVERT(float,Receita)) MediaReceitaPedido,MIN(Receita) MinimoReceitaPedido,
 MAX(Receita) MaximoReceitaPedido,STDEVP(CONVERT(float,Receita)) DesvioPadraoPopulacional,
 VARP(CONVERT(float,Receita)) VarianciaPopulacional FROM P;

-- Grão: produto, com mediana por categoria sem duplicação analítica.
WITH P AS (
 SELECT f.ProductID,p.Categoria,SUM(f.ReceitaProdutosAposDesconto) Receita
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimProduto p ON p.ProductID=f.ProductID GROUP BY f.ProductID,p.Categoria
), M AS (
 SELECT *,PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Receita) OVER(PARTITION BY Categoria) Mediana FROM P
)
SELECT Categoria,COUNT(*) N,AVG(CONVERT(float,Receita)) MediaReceitaProduto,MAX(Mediana) MedianaReceitaProduto,
 MIN(Receita) Minimo,MAX(Receita) Maximo,STDEVP(CONVERT(float,Receita)) DesvioPadraoPopulacional,
 VARP(CONVERT(float,Receita)) VarianciaPopulacional FROM M GROUP BY Categoria ORDER BY Categoria;

-- Grão: cliente.
WITH C AS (SELECT CustomerID,SUM(ReceitaProdutosAposDesconto) Receita FROM dbo.vw_FactVendas GROUP BY CustomerID)
SELECT COUNT(*) N,AVG(CONVERT(float,Receita)) MediaReceitaCliente,MIN(Receita) Minimo,MAX(Receita) Maximo,
 STDEVP(CONVERT(float,Receita)) DesvioPadraoPopulacional,VARP(CONVERT(float,Receita)) VarianciaPopulacional FROM C;

-- Grão: território comercial do pedido, incluindo nulo.
WITH T AS (SELECT TerritoryID,SUM(ReceitaProdutosAposDesconto) Receita FROM dbo.vw_FactVendas GROUP BY TerritoryID)
SELECT COUNT(*) N,AVG(CONVERT(float,Receita)) MediaReceitaTerritorio,MIN(Receita) Minimo,MAX(Receita) Maximo,
 STDEVP(CONVERT(float,Receita)) DesvioPadraoPopulacional,VARP(CONVERT(float,Receita)) VarianciaPopulacional FROM T;
GO
