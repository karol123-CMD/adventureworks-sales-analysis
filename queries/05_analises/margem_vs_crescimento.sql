/* Objetivo: comparar receita e margem estimada anual por categoria.
Grão: categoria-ano. Universo: padrão. Receita: após desconto, sem imposto/frete.
Custo: histórico com fallback da fato. Limitação: YoY só é exibido para anos completos consecutivos. */
USE AdventureWorks2022;
GO

WITH Anual AS (
 SELECT COALESCE(pc.ProductCategoryID,-1) ProductCategoryID,p.Categoria,YEAR(f.OrderDate) Ano,
  MAX(CONVERT(int,c.AnoCompleto)) AnoCompleto,SUM(f.ReceitaProdutosAposDesconto) Receita,
  SUM(f.CustoTotal) CustoEstimado,SUM(f.MargemBrutaEstimadaValor) MargemEstimada
 FROM dbo.vw_FactVendas f JOIN dbo.vw_DimProduto p ON p.ProductID=f.ProductID
 LEFT JOIN Production.Product prod ON prod.ProductID=f.ProductID
 LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID=prod.ProductSubcategoryID
 LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID=ps.ProductCategoryID
 JOIN dbo.vw_DimCalendario c ON c.[Date]=f.OrderDate
 GROUP BY COALESCE(pc.ProductCategoryID,-1),p.Categoria,YEAR(f.OrderDate)
)
SELECT a.ProductCategoryID,a.Categoria,a.Ano,a.AnoCompleto,a.Receita,a.CustoEstimado,a.MargemEstimada,
 CONVERT(decimal(19,6),a.MargemEstimada/NULLIF(a.Receita,0)) MargemBrutaEstimadaPercentual,
 CASE WHEN a.AnoCompleto=1 AND ant.AnoCompleto=1
  THEN CONVERT(decimal(19,6),(a.Receita-ant.Receita)/NULLIF(ant.Receita,0)) END CrescimentoYoY,
 CASE WHEN a.AnoCompleto=1 AND ant.AnoCompleto=1 THEN N'Comparável' ELSE N'Não comparável: período incompleto ou anterior ausente' END StatusComparacao
FROM Anual a LEFT JOIN Anual ant ON ant.ProductCategoryID=a.ProductCategoryID AND ant.Ano=a.Ano-1
ORDER BY a.Categoria,a.Ano;
GO
