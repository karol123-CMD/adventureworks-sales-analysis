/* Objetivo: validar dimensões e órfãos. Grão: dimensão/chave.
Universo: views analíticas. Receita/custo: não aplicável. Limitação: somente leitura. */
USE AdventureWorks2022;
GO
SELECT 'DimCliente' Dimensao,COUNT_BIG(*) Linhas,COUNT(DISTINCT CustomerID) ChavesDistintas FROM dbo.vw_DimCliente
UNION ALL SELECT 'DimProduto',COUNT_BIG(*),COUNT(DISTINCT ProductID) FROM dbo.vw_DimProduto
UNION ALL SELECT 'DimTerritorio',COUNT_BIG(*),COUNT(DISTINCT TerritoryID) FROM dbo.vw_DimTerritorio
UNION ALL SELECT 'DimCalendario',COUNT_BIG(*),COUNT(DISTINCT [Date]) FROM dbo.vw_DimCalendario;

SELECT TipoCliente,COUNT_BIG(*) Clientes FROM dbo.vw_DimCliente GROUP BY TipoCliente ORDER BY TipoCliente;
SELECT Categoria,Subcategoria,COUNT_BIG(*) Produtos FROM dbo.vw_DimProduto GROUP BY Categoria,Subcategoria ORDER BY Categoria,Subcategoria;
SELECT SUM(CASE WHEN TerritoryID IS NULL THEN 1 ELSE 0 END) LinhasFatoSemTerritorio FROM dbo.vw_FactVendas;

SELECT 'Cliente' Dimensao,COUNT_BIG(*) Orfaos FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimCliente d ON d.CustomerID=f.CustomerID WHERE d.CustomerID IS NULL
UNION ALL SELECT 'Produto',COUNT_BIG(*) FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimProduto d ON d.ProductID=f.ProductID WHERE d.ProductID IS NULL
UNION ALL SELECT 'Territorio',COUNT_BIG(*) FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimTerritorio d ON d.TerritoryID=f.TerritoryID WHERE f.TerritoryID IS NOT NULL AND d.TerritoryID IS NULL
UNION ALL SELECT 'Calendario',COUNT_BIG(*) FROM dbo.vw_FactVendas f LEFT JOIN dbo.vw_DimCalendario d ON d.[Date]=f.OrderDate WHERE d.[Date] IS NULL;
GO
