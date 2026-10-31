/* Controles globais para confrontar com o Power BI, sem filtros.
   Somente leitura. Estatísticas sobre clientes com receita, por CustomerID.
   Não executa DAX nem comprova o comportamento dos visuais. */
USE AdventureWorks2022;
GO
WITH B AS (
 SELECT CustomerID,SUM(ReceitaProdutosAposDesconto) Receita
 FROM dbo.vw_FactVendas GROUP BY CustomerID
), Q AS (
 SELECT *,PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Receita) OVER() Q1,
 PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Receita) OVER() Mediana,
 PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Receita) OVER() Q3,
 ROW_NUMBER() OVER(ORDER BY Receita DESC,CustomerID) Posicao,
 SUM(Receita) OVER(ORDER BY Receita DESC,CustomerID ROWS UNBOUNDED PRECEDING) Acumulada
 FROM B
)
SELECT COUNT(*) ClientesAtivos,SUM(Receita) ReceitaTotal,AVG(Receita) ReceitaMediaCliente,
 MAX(Mediana) Mediana,MAX(Q1) Q1,MAX(Q3) Q3,
 SUM(CASE WHEN Receita>Q3+1.5*(Q3-Q1) THEN 1 ELSE 0 END) OutliersSuperiores,
 SUM(CASE WHEN Posicao<=10 THEN Receita ELSE 0 END) ReceitaTop10,
 SUM(CASE WHEN Posicao<=10 THEN Receita ELSE 0 END)/SUM(Receita) ParticipacaoTop10,
 MAX(CASE WHEN Posicao=1 THEN Acumulada END)/SUM(Receita) Pareto1,
 MAX(CASE WHEN Posicao=10 THEN Acumulada END)/SUM(Receita) Pareto10,
 MAX(CASE WHEN Posicao=20 THEN Acumulada END)/SUM(Receita) Pareto20
FROM Q;
GO
