# Base AdventureWorks2022 OLTP

O banco não é distribuído neste repositório. O projeto usa exclusivamente o **AdventureWorks2022 OLTP**, banco de exemplo da Microsoft; a variante Data Warehouse não é compatível com estes scripts.

## Requisitos

- SQL Server compatível com o backup AdventureWorks2022;
- SSMS, Azure Data Studio ou `sqlcmd`;
- permissão para restaurar o banco e, depois, criar/alterar somente as views analíticas em `dbo`.

## Obtenção e restauração

Baixe o backup na [página oficial da Microsoft](https://learn.microsoft.com/sql/samples/adventureworks-install-configure) e selecione `AdventureWorks2022.bak` sem o sufixo `DW`.

No SSMS, use **Databases > Restore Database > Device**. Os caminhos de dados e log dependem da instância; não copie caminhos específicos de outro computador. Confirme que o banco restaurado se chama `AdventureWorks2022`.

## Teste da conexão

```sql
USE AdventureWorks2022;
SELECT DB_NAME() AS Banco,
       SERVERPROPERTY('ProductVersion') AS VersaoSQLServer;
SELECT OBJECT_ID('Sales.SalesOrderHeader') AS SalesOrderHeaderID,
       OBJECT_ID('Sales.SalesOrderDetail') AS SalesOrderDetailID,
       OBJECT_ID('Production.Product') AS ProductID;
```

Em instância nomeada, substitua o servidor configurado no cliente, por exemplo `NOME_DO_SERVIDOR\NOME_DA_INSTANCIA`. Use autenticação integrada quando disponível; não grave senhas no projeto.

## Perfil mínimo

```sql
SELECT MIN(OrderDate) AS DataMinima, MAX(OrderDate) AS DataMaxima
FROM Sales.SalesOrderHeader;

SELECT Status, COUNT_BIG(*) AS Pedidos
FROM Sales.SalesOrderHeader
GROUP BY Status
ORDER BY Status;
```

## Ordem dos scripts

Consulte [queries/README.md](../queries/README.md). Em resumo:

1. execute exploração e qualidade;
2. execute, na ordem numérica, os cinco scripts de `03_camada_analitica`;
3. execute `07_validacao`;
4. execute KPIs, análises e estatística;
5. registre qualquer divergência antes de abrir o Power BI.

As views criadas são `dbo.vw_FactVendas`, `dbo.vw_DimCliente`, `dbo.vw_DimProduto`, `dbo.vw_DimTerritorio` e `dbo.vw_DimCalendario`.

## Segurança e versionamento

Não envie ao Git arquivos `.bak`, `.mdf`, `.ndf`, `.ldf`, credenciais, strings com senha ou arquivos `.env`. O `.gitignore` da raiz cobre esses padrões, mas não substitui a revisão antes de cada commit.
