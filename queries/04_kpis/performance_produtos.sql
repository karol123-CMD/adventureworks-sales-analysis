/* Objetivo: performance, margem estimada, ranking e Pareto por ProductID.
Grão: produto. Universo: padrão da vw_FactVendas. Receita: após desconto, sem imposto/frete.
Custo: histórico com fallback explícito. Limitação: categorias ausentes são preservadas. */
USE AdventureWorks2022;
GO

WITH Produto AS (
 SELECT f.ProductID,p.NomeProduto,p.Subcategoria,p.Categoria,
  SUM(f.ReceitaProdutosAposDesconto) AS Receita,SUM(f.OrderQty) AS Unidades,
  SUM(f.CustoTotal) AS Custo,SUM(f.MargemBrutaEstimadaValor) AS Margem
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimProduto p ON p.ProductID=f.ProductID
 GROUP BY f.ProductID,p.NomeProduto,p.Subcategoria,p.Categoria
)
SELECT ProductID,NomeProduto,Subcategoria,Categoria,Receita,Unidades,Custo,Margem,
 CONVERT(decimal(19,6),Margem/NULLIF(Receita,0)) AS MargemBrutaEstimadaPercentual,
 DENSE_RANK() OVER(ORDER BY Receita DESC) AS RankingReceita,
 CONVERT(decimal(19,6),Receita/NULLIF(SUM(Receita) OVER(),0)) AS ParticipacaoReceita
FROM Produto ORDER BY Receita DESC,ProductID;

WITH Base AS (
 SELECT f.ProductID,MAX(p.NomeProduto) AS NomeProduto,SUM(f.ReceitaProdutosAposDesconto) AS Receita
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimProduto p ON p.ProductID=f.ProductID GROUP BY f.ProductID
), Ordenada AS (
 SELECT *,ROW_NUMBER() OVER(ORDER BY Receita DESC,ProductID) AS Posicao,COUNT(*) OVER() AS TotalProdutos,
  SUM(Receita) OVER() AS ReceitaTotal,
  SUM(Receita) OVER(ORDER BY Receita DESC,ProductID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ReceitaAcumulada,
  SUM(Receita) OVER(ORDER BY Receita DESC,ProductID ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS ReceitaAcumuladaAnterior
 FROM Base
), Pareto AS (
 SELECT *,CONVERT(decimal(19,6),ReceitaAcumulada/NULLIF(ReceitaTotal,0)) AS PercentualReceitaAcumulada,
  CONVERT(decimal(19,6),Posicao*1.0/NULLIF(TotalProdutos,0)) AS PercentualProdutosAcumulado,
  CASE WHEN COALESCE(ReceitaAcumuladaAnterior,0)<ReceitaTotal*0.80 THEN 'A'
       WHEN COALESCE(ReceitaAcumuladaAnterior,0)<ReceitaTotal*0.95 THEN 'B' ELSE 'C' END AS ClasseABC
 FROM Ordenada
)
SELECT ProductID,NomeProduto,Receita,Posicao,TotalProdutos,ReceitaAcumulada,
 PercentualReceitaAcumulada,PercentualProdutosAcumulado,ClasseABC
FROM Pareto ORDER BY Posicao;

WITH B AS (SELECT ProductID,SUM(ReceitaProdutosAposDesconto) Receita FROM dbo.vw_FactVendas GROUP BY ProductID),
O AS (SELECT *,ROW_NUMBER() OVER(ORDER BY Receita DESC,ProductID) Posicao,COUNT(*) OVER() Total,
 SUM(Receita) OVER() TotalReceita,SUM(Receita) OVER(ORDER BY Receita DESC,ProductID ROWS UNBOUNDED PRECEDING) Acumulada FROM B),
L AS (SELECT MIN(Posicao) QuantidadePara80,MAX(Total) TotalProdutos FROM O WHERE Acumulada>=TotalReceita*0.80)
SELECT QuantidadePara80,TotalProdutos,CONVERT(decimal(19,6),QuantidadePara80*1.0/NULLIF(TotalProdutos,0)) AS PercentualProdutosPara80 FROM L;
GO
