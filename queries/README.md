# Camada SQL

## Regra canônica

O universo padrão usa pedidos enviados (`Status=5`), `LineTotal>0` e `OrderQty>0`. `LineTotal` representa itens após desconto, sem impostos e frete. As análises consomem preferencialmente `dbo.vw_FactVendas` para evitar divergência.

## Pastas e ordem

| Ordem | Pasta | Finalidade | Operação |
|---:|---|---|---|
| 1 | `01_exploracao` | versão, schema, PK/FK, período e objetos | somente leitura |
| 2 | `02_qualidade` | integridade, datas, valores, conciliação e custo | somente leitura |
| 3 | `03_camada_analitica` | fato, dimensões e calendário | `CREATE OR ALTER VIEW` |
| 4 | `07_validacao` | universo, views, dimensões, custo e KPIs | somente leitura |
| 5 | `04_kpis` | KPIs financeiros, produtos, territórios e clientes | somente leitura |
| 6 | `05_analises` | tempo, região e margem versus crescimento | somente leitura |
| 7 | `06_estatistica` | descrição, quartis e Tukey | somente leitura |

Execute os arquivos de `03_camada_analitica` e `07_validacao` na ordem numérica. Todos exigem conexão com `AdventureWorks2022`; somente os cinco scripts de views modificam metadados, dentro da autorização `CREATE OR ALTER VIEW`.

Os arquivos estão em UTF-8. Ao usar sqlcmd, informe `-f 65001 -b` para preservar os literais acentuados e sinalizar falhas; configure servidor, banco, autenticação e certificado da sua instância.

## Views

- `vw_FactVendas`: uma linha por `SalesOrderDetailID`, universo padrão e custo temporal/fallback.
- `vw_DimCliente`: uma linha por `CustomerID`, incluindo pessoa e loja.
- `vw_DimProduto`: uma linha por `ProductID`, sem filtros excludentes.
- `vw_DimTerritorio`: uma linha por `TerritoryID`; preserva colunas legadas requeridas pelo Power Query.
- `vw_DimCalendario`: uma linha por data; ainda não é consumida pelo TMDL atual.

## Validação

Critério básico: chaves das dimensões e fato únicas, nenhum órfão inesperado, diferença zero entre consulta direta e fato, e divergências de cabeçalho/detalhe dentro da tolerância de 0,01. A cobertura de custo histórico e qualquer fallback precisam ser reportados, não ocultados.

Resultados vazios em testes de anomalia significam ausência de ocorrências sob a regra testada; não provam qualidade total. Outliers são observações para investigação, não erros.

## Power BI

As quatro views legadas mantêm os nomes e tipos esperados pelo TMDL. Colunas extras são documentadas em [mapeamento_sql_powerbi.md](../docs/mapeamento_sql_powerbi.md). O manifesto TMDL/M está em `powerbi/Model`; o PBIX principal fica na raiz.

## Limitações

Em 11/10/2026, os 18 scripts de leitura foram reexecutados após corrigir a vigência inclusiva de custo. Os sete validadores e a conciliação territorial independente foram revisados. Veja os [resultados registrados](../docs/validacao_sql_dax.md). Permanecem 64 linhas com fallback de custo, condição documentada e incorporada à margem estimada. A atualização e a conciliação do PBIX foram concluídas na validação registrada; esta revisão documental não reexecutou os testes nem atualizou dados.
