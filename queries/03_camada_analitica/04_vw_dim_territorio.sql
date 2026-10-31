/* Objetivo: dimensão territorial compatível com o Power BI. Grão: TerritoryID. Universo: cadastro completo.
Receita/custo: métricas legadas são preservadas, mas não usadas nos KPIs. Limitação: não inclui sentinela para nulos. */
USE AdventureWorks2022;
GO
CREATE OR ALTER VIEW dbo.vw_DimTerritorio AS
SELECT TerritoryID,Name AS Territorio,CountryRegionCode,[Group] AS GrupoRegiao,
       SalesYTD,SalesLastYear,CostYTD,CostLastYear
FROM Sales.SalesTerritory;
GO
