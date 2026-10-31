# Mapeamento SQL-Power BI

Contrato das views com o snapshot TMDL/M em `powerbi/Model`. O PBIX é a fonte canônica; o escopo e a sincronização comprovada do snapshot estão descritos em [`powerbi/Model/README.md`](../powerbi/Model/README.md).

| View | Coluna SQL | Significado | Tipo esperado | Consumida pelo Power BI | Observação |
|---|---|---|---|---|---|
| vw_FactVendas | SalesOrderDetailID | chave do grão | int | Sim | validar unicidade |
| vw_FactVendas | SalesOrderID | pedido | int | Sim | distinct em pedidos |
| vw_FactVendas | OrderDate | data principal | date | Sim | convertida para date pelo M |
| vw_FactVendas | CustomerID/ProductID/TerritoryID | chaves dimensionais | int | Sim | território pode ser nulo |
| vw_FactVendas | OrderQty/UnitPrice | quantidade/preço | smallint/money | Sim | nomes legados |
| vw_FactVendas | LineTotal | itens após desconto, sem imposto/frete | numeric calculado | Sim | nome legado obrigatório |
| vw_FactVendas | StandardCost | custo padrão atual | money | Sim | nome legado; não é custo histórico |
| vw_FactVendas | CustoTotal | custo estimado usado | decimal(19,4) | Sim | agora usa histórico/fallback |
| vw_FactVendas | LucroBruto | margem estimada em valor | decimal(19,4) | Sim | nome legado |
| vw_FactVendas | Status | status do pedido | tinyint | Sim | fato filtrada em 5 |
| vw_FactVendas | ReceitaProdutosAposDesconto | alias semântico de LineTotal | numeric | Sim, no TMDL | receita canônica |
| vw_FactVendas | CustoUnitarioHistorico/Atual/Utilizado | rastreabilidade de custo | money/decimal | Sim, no TMDL | rastreabilidade |
| vw_FactVendas | FonteCusto/IndicadorFallback | qualidade do custo | nvarchar/bit | Sim, no TMDL | rastreabilidade |
| vw_DimCliente | CustomerID/PersonID/StoreID/TerritoryID | chaves | int | Sim | uma linha por CustomerID |
| vw_DimCliente | TipoCliente/NomeCliente | exibição unificada | nvarchar | Sim | inclui lojas |
| vw_DimProduto | ProductID/NomeProduto | chave/nome | int/nvarchar | Sim | uma linha por produto |
| vw_DimProduto | Subcategoria/Categoria | classificação | nvarchar | Sim | valores Sem classificação |
| vw_DimProduto | ProductNumber/Color/StandardCost/ListPrice | atributos | vários | Sim | sem filtros |
| vw_DimProduto | SellStartDate/SellEndDate/FinishedGoodsFlag | ciclo de vida | date/bit | Sim | datas convertidas pelo M |
| vw_DimTerritorio | TerritoryID/Territorio/CountryRegionCode/GrupoRegiao | dimensão territorial | vários | Sim | contrato principal |
| vw_DimTerritorio | SalesYTD/SalesLastYear/CostYTD/CostLastYear | métricas legadas | money | Removidas pelo M | precisam existir para `Table.RemoveColumns` não falhar |
| vw_DimCalendario | Date e atributos | calendário denso SQL | vários | Não atualmente | candidata à migração; calendário atual é DAX |

O snapshot TMDL também declara MargemBrutaEstimadaValor e MargemBrutaEstimadaPercentual. O Power Query importa quatro partições M: fato, cliente, produto e território. O calendário ativo é calculado em DAX; `vw_DimCalendario` permanece disponível para análises e validações SQL. Os relacionamentos filtram das dimensões para a fato. Conferir [conciliação SQL-DAX](validacao_sql_dax.md) após refresh.
