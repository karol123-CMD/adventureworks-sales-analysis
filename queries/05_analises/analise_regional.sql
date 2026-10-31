/* Objetivo: contextualizar receita e dispersão por território comercial do pedido.
Grão: TerritoryID. Universo: padrão. Receita: após desconto, sem imposto/frete.
Custo: não utilizado. Limitação: abaixo da média é descrição, não potencial comprovado. */
USE AdventureWorks2022;
GO

WITH Territorio AS (
 SELECT f.TerritoryID,COALESCE(t.Territorio,N'Sem território') Territorio,
  SUM(f.ReceitaProdutosAposDesconto) Receita,COUNT(DISTINCT f.SalesOrderID) Pedidos,
  COUNT(DISTINCT f.CustomerID) Clientes
 FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimTerritorio t ON t.TerritoryID=f.TerritoryID
 GROUP BY f.TerritoryID,t.Territorio
), Contexto AS (
 SELECT *,AVG(Receita) OVER() MediaReceita,STDEVP(CONVERT(float,Receita)) OVER() DesvioPadraoPopulacional,
  VARP(CONVERT(float,Receita)) OVER() VarianciaPopulacional,SUM(Receita) OVER() ReceitaTotal,
  COUNT(*) OVER() QuantidadeTerritorios
 FROM Territorio
)
SELECT TerritoryID,Territorio,Receita,Pedidos,Clientes,
 CONVERT(decimal(19,4),Receita/NULLIF(Pedidos,0)) TicketMedio,
 CONVERT(decimal(19,6),Receita/NULLIF(ReceitaTotal,0)) Participacao,
 MediaReceita,Receita-MediaReceita AS DesvioDaMedia,DesvioPadraoPopulacional,VarianciaPopulacional,
 CONVERT(decimal(19,6),DesvioPadraoPopulacional/NULLIF(MediaReceita,0)) CoeficienteVariacao,
 QuantidadeTerritorios,
 CASE WHEN Receita<MediaReceita THEN N'Receita inferior à média no período analisado' ELSE N'Receita igual ou superior à média no período analisado' END ClassificacaoDescritiva
FROM Contexto ORDER BY Receita DESC,COALESCE(TerritoryID,-1);
GO
