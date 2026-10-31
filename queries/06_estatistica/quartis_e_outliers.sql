/* Objetivo: identificar observações estatisticamente extremas pela regra de Tukey.
Grãos: ProductID; CustomerID; CustomerID+TerritoryID. Universo: padrão.
Receita: após desconto, sem imposto/frete. Limitação: outlier não significa erro; grupos pequenos exigem cautela. */
USE AdventureWorks2022;
GO

-- Produtos dentro de categoria.
WITH B AS (
 SELECT f.ProductID,p.NomeProduto,p.Categoria,SUM(f.ReceitaProdutosAposDesconto) Valor
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimProduto p ON p.ProductID=f.ProductID GROUP BY f.ProductID,p.NomeProduto,p.Categoria
), Q AS (
 SELECT *,COUNT(*) OVER(PARTITION BY Categoria) N,
  PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Valor) OVER(PARTITION BY Categoria) Q1,
  PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Valor) OVER(PARTITION BY Categoria) Q3 FROM B
)
SELECT ProductID,NomeProduto,Categoria,N,Valor,Q1,Q3,Q3-Q1 IQR,Q1-1.5*(Q3-Q1) LimiteInferior,Q3+1.5*(Q3-Q1) LimiteSuperior,
 CASE WHEN Valor<Q1-1.5*(Q3-Q1) OR Valor>Q3+1.5*(Q3-Q1) THEN N'Observação estatisticamente extrema' ELSE N'Dentro dos limites de Tukey' END Classificacao
FROM Q ORDER BY Categoria,Valor DESC,ProductID;

-- Clientes pessoa, loja ou não identificado no universo global.
WITH B AS (
 SELECT f.CustomerID,MAX(c.NomeCliente) NomeCliente,MAX(c.TipoCliente) TipoCliente,SUM(f.ReceitaProdutosAposDesconto) Valor
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimCliente c ON c.CustomerID=f.CustomerID GROUP BY f.CustomerID
), Q AS (
 SELECT *,COUNT(*) OVER() N,PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Valor) OVER() Q1,
  PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Valor) OVER() Q3 FROM B
)
SELECT CustomerID,NomeCliente,TipoCliente,N,Valor,Q1,Q3,Q3-Q1 IQR,Q1-1.5*(Q3-Q1) LimiteInferior,Q3+1.5*(Q3-Q1) LimiteSuperior,
 CASE WHEN Valor<Q1-1.5*(Q3-Q1) OR Valor>Q3+1.5*(Q3-Q1) THEN N'Observação estatisticamente extrema' ELSE N'Dentro dos limites de Tukey' END Classificacao
FROM Q ORDER BY Valor DESC,CustomerID;

-- Cliente por território comercial do pedido; N<20 é sinalizado apenas como cautela analítica.
WITH B AS (
 SELECT f.TerritoryID,f.CustomerID,SUM(f.ReceitaProdutosAposDesconto) Valor
 FROM dbo.vw_FactVendas f GROUP BY f.TerritoryID,f.CustomerID
), Q AS (
 SELECT *,COUNT(*) OVER(PARTITION BY TerritoryID) N,
  PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Valor) OVER(PARTITION BY TerritoryID) Q1,
  PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Valor) OVER(PARTITION BY TerritoryID) Q3 FROM B
)
SELECT TerritoryID,CustomerID,N,Valor,Q1,Q3,Q3-Q1 IQR,Q1-1.5*(Q3-Q1) LimiteInferior,Q3+1.5*(Q3-Q1) LimiteSuperior,
 CASE WHEN N<20 THEN N'Grupo pequeno: interpretar com cautela' ELSE N'Tamanho de grupo não sinalizado' END AvaliacaoTamanhoGrupo,
 CASE WHEN Valor<Q1-1.5*(Q3-Q1) OR Valor>Q3+1.5*(Q3-Q1) THEN N'Observação estatisticamente extrema' ELSE N'Dentro dos limites de Tukey' END Classificacao
FROM Q ORDER BY COALESCE(TerritoryID,-1),Valor DESC,CustomerID;
GO
