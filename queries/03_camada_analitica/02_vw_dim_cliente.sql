/* Objetivo: dimensão unificada de clientes. Grão: CustomerID. Universo: cadastro completo.
Receita/custo: não aplicável. Limitação: nome de exibição usa fallback quando ausente. */
USE AdventureWorks2022;
GO
CREATE OR ALTER VIEW dbo.vw_DimCliente AS
SELECT c.CustomerID,c.PersonID,c.StoreID,c.TerritoryID,
 CASE WHEN c.StoreID IS NOT NULL THEN N'Loja' WHEN c.PersonID IS NOT NULL THEN N'Pessoa' ELSE N'Não identificado' END AS TipoCliente,
 CASE WHEN c.StoreID IS NOT NULL THEN COALESCE(NULLIF(LTRIM(RTRIM(s.Name)),''),CONCAT(N'Cliente ',c.CustomerID))
      WHEN c.PersonID IS NOT NULL THEN COALESCE(NULLIF(LTRIM(RTRIM(CONCAT_WS(' ',p.FirstName,p.MiddleName,p.LastName))),''),CONCAT(N'Cliente ',c.CustomerID))
      ELSE CONCAT(N'Cliente ',c.CustomerID) END AS NomeCliente
FROM Sales.Customer c
LEFT JOIN Person.Person p ON p.BusinessEntityID=c.PersonID
LEFT JOIN Sales.Store s ON s.BusinessEntityID=c.StoreID;
GO
