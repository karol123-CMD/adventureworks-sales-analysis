# Regras de negócio da camada SQL

## Escopo

Fonte: `AdventureWorks2022` OLTP, banco de exemplo da Microsoft. Não há uso de AdventureWorksDW nem alegação de dados operacionais reais.

| Tema | Regra canônica | Fonte | Exceção/limitação |
|---|---|---|---|
| Universo | `Status=5`, `LineTotal>0`, `OrderQty>0` | Header + Detail | significado de 5 deve ser confirmado na instância; no modelo AdventureWorks corresponde a enviado |
| Receita | valor dos itens após desconto, sem impostos e frete | `LineTotal` | `TaxAmt`, `Freight` e `TotalDue` são separados |
| Pedidos | distinct `SalesOrderID` | fato | nenhuma |
| Ticket | receita de produtos / pedidos | fato | divisão protegida por `NULLIF` |
| Custo | custo histórico cujo intervalo contém `OrderDate` | `ProductCostHistory` | `StartDate <= OrderDate <= EndDate`; término nulo representa vigência aberta; datas diárias verificadas |
| Fallback | `Product.StandardCost` atual quando não há custo histórico | Product | identificado por fonte e indicador |
| Margem | receita menos custo utilizado | fato | denominada margem bruta estimada; não margem histórica real quando há fallback |
| Cliente | chave `CustomerID`; tipos Pessoa, Loja ou Não identificado | Customer/Person/Store | território cadastral não substitui território do pedido |
| Produto | chave `ProductID`; left join para classificação | Product hierarchy | sem filtro padrão de ListPrice ou FinishedGoodsFlag |
| Território | `SalesOrderHeader.TerritoryID` | Header | nulo exibido como Sem território nas análises |
| Data | `OrderDate`; calendário denso ativo calculado em DAX | Header + `DimCalendario` DAX | `vw_DimCalendario` apoia SQL/validações; anos incompletos não entram em comparação anual equivalente |
| Estatística | grão declarado e `STDEVP`/`VARP` para população disponível | fato | amostra exigiria justificativa explícita |
| Outlier | observação fora dos limites de Tukey | Q1/Q3 | não é automaticamente erro |
| Moeda | formatação neutra em unidades monetárias | documentação | cultura de exibição não define moeda |

## Custo temporal

A fato usa `OUTER APPLY TOP (1)` ordenado por `StartDate` para impedir multiplicação. A validação conta zero, uma ou múltiplas correspondências antes que o `TOP (1)` selecione uma linha. Sobreposição histórica é problema de qualidade e não deve ser mascarada.

Em 11/10/2026, a convenção inclusiva foi adotada com base nos dados desta instância: 102 transições entre históricos terminam em 29/05 e reiniciam em 30/05; nenhuma sobreposição inclusiva foi encontrada. Custos e pedidos usam horários à meia-noite. A inclusão do último dia recupera 16 linhas históricas e reduz os fallbacks de 80 para 64, sem multiplicar vendas. Esta é a convenção analítica do projeto para a base observada; não deve ser generalizada a fontes com timestamps sem nova validação. O validador de custo verifica horários, intervalos inválidos e sobreposições.

## Períodos equivalentes

MoM usa o mês calendário anterior em série densa. YoY mensal usa o mesmo mês do ano anterior. Comparações anuais só são calculadas quando ano atual e anterior estão marcados como completos.

No modelo Power BI, as dimensões filtram a fato em relacionamentos muitos-para-um. No cartão "YoY - último período válido", a validação manual registrou branco para 2011, 2012 e 2014 e 30,12% para 2013 e para "Todos".

## Execução e limites

Em 11/10/2026, foram revalidados período, meses presentes, cobertura de custo, territórios, tipos de cliente, conciliação header/detail e identidade de `TotalDue`. Os pedidos observados têm status 5 e data de envio. A revisão final também cobriu refresh, execução DAX e interações no Power BI. Consulte os resultados em [validação SQL-DAX](validacao_sql_dax.md).
