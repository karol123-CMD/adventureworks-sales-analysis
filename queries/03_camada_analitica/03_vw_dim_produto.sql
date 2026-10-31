/* Objetivo: dimensão de produtos sem filtros excludentes. Grão: ProductID. Universo: catálogo completo.
Receita/custo: StandardCost é atributo atual, não custo histórico. Limitação: classificações ausentes recebem rótulo. */
USE AdventureWorks2022;
GO
CREATE OR ALTER VIEW dbo.vw_DimProduto AS
SELECT p.ProductID,p.Name AS NomeProduto,COALESCE(ps.Name,N'Sem subcategoria') AS Subcategoria,
       COALESCE(pc.Name,N'Sem categoria') AS Categoria,p.ProductNumber,p.Color,p.StandardCost,p.ListPrice,
       CONVERT(date,p.SellStartDate) AS SellStartDate,CONVERT(date,p.SellEndDate) AS SellEndDate,p.FinishedGoodsFlag
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID=p.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID=ps.ProductCategoryID;
GO
