# Dicionário de medidas DAX

Referência textual: `powerbi/Model/tables/Medidas.tmdl`, com 98 medidas físicas. As pastas abaixo agrupam conceitos; consulte o TMDL para o DisplayFolder literal. A igualdade das 98 expressões foi confirmada no inventário de 10/09/2026, mas isso não comprova sincronização integral posterior. Em 30/10/2026, a expressão de `Crescimento YoY %` foi relida do modelo ativo por TOM/ADOMD e sincronizada no snapshot; os resultados DAX continuam documentados pela validação do PBIX canônico. Veja o [escopo do manifesto](../powerbi/Model/README.md).

Status usados: **revisada estaticamente** não significa executada; **legada compatível** indica alias preservado porque há referências no relatório ou em outras medidas.

| Medida | Pasta | Definição | Finalidade | Formato | Dependências | Status |
|---|---|---|---|---|---|---|
| Receita de Produtos | 01 Base | Soma da receita dos itens após desconto | Receita canônica | `#,##0.00` | Fato | Revisada estaticamente |
| Unidades Vendidas | 01 Base | Soma de `OrderQty` | Volume vendido | `#,##0` | Fato | Revisada estaticamente |
| Pedidos | 01 Base | Contagem distinta de pedidos | Pedidos enviados | `#,##0` | Fato | Revisada estaticamente |
| Clientes Ativos | 01 Base | Contagem distinta de clientes na fato | Clientes com compra | `#,##0` | Fato | Revisada estaticamente |
| Produtos Vendidos | 01 Base | Contagem distinta de produtos na fato | Produtos com venda | `#,##0` | Fato | Revisada estaticamente |
| Clientes Cadastrados | 01 Base | Contagem distinta na dimensão | Base cadastrada | `#,##0` | DimCliente | Revisada estaticamente |
| Produtos Cadastrados | 01 Base | Contagem distinta na dimensão | Catálogo cadastrado | `#,##0` | DimProduto | Revisada estaticamente |
| Custo Total Estimado | 01 Base | Soma do custo total | Custo com histórico/fallback | `#,##0.00` | Fato | Revisada estaticamente |
| Margem Bruta Estimada | 01 Base | Soma da margem estimada | Margem em valor | `#,##0.00` | Fato | Revisada estaticamente |
| Margem Bruta Estimada % | 01 Base | Margem dividida pela receita | Margem percentual | `0.00%` | Medidas base | Revisada estaticamente |
| Ticket Médio | 01 Base | Receita dividida por pedidos | Valor médio por pedido | `#,##0.00` | Medidas base | Revisada estaticamente |
| Receita Média por Cliente | 01 Base | Receita dividida por clientes ativos | Média por cliente | `#,##0.00` | Medidas base | Revisada estaticamente |
| Receita Média por Produto | 01 Base | Receita dividida por produtos vendidos | Média por produto | `#,##0.00` | Medidas base | Revisada estaticamente |
| Receita Total; Quantidade Vendida; Total de Pedidos; Custo Total; Lucro Bruto; Margem Bruta % | 99 Legado | Aliases das medidas canônicas | Compatibilidade com visuais existentes | Neutro | Medidas base | Legadas compatíveis; não remover antes de migrar usos |
| Preço Médio Unitário | 01 Base | Média de preço unitário | Preço médio no contexto | `#,##0.00` | Fato | Revisada estaticamente |
| Receita Mesmo Período Ano Anterior; Receita Ano Anterior | 02 Tempo | Mesmo período no ano anterior | Base YoY | `#,##0.00` | Calendário e receita | Revisada estaticamente |
| Crescimento YoY; Crescimento YoY % | 02 Tempo | Variação contra período equivalente anterior; no total, `Crescimento YoY %` usa o ano completo mais recente | Evolução anual | Valor / `0.00%` | Medidas temporais | Expressão de `%` sincronizada do PBIX em 30/10/2026; 2011, 2012 e 2014 em branco, 2013 e Todos = 30,12% |
| Receita Mês Anterior; Crescimento MoM; Crescimento MoM % | 02 Tempo | Comparação com mês calendário anterior | Evolução mensal | Valor / `0.00%` | Calendário e receita | Revisada estaticamente |
| Receita Acumulada no Ano; Receita YTD | 02 Tempo | Acumulado no ano | Tendência YTD | `#,##0.00` | Calendário e receita | Revisada estaticamente |
| Pedidos Mês Anterior; Variação de Pedidos | 02 Tempo | Pedidos no período anterior e variação | Evolução de pedidos | Número / percentual | Calendário e pedidos | Revisada estaticamente |
| Margem no Período Anterior; Ticket no Período Anterior | 02 Tempo | Indicador no período anterior | Comparação temporal | Neutro | Calendário e medidas base | Revisada estaticamente |
| Aviso de Período Parcial | 02 Tempo | Detecta ano de borda da série | Alerta 2011/2014 | Texto | DimCalendario | Revisada estaticamente |
| Margem Bruta % Ano Anterior; Variação Margem YoY p.p. | 02 Tempo | Margem anterior e diferença em pontos percentuais | Evolução de margem | `0.00%` | Calendário e margem | Revisada estaticamente |
| Participação Receita Categoria %; Ranking Categoria Receita | 03 Ranking | Participação e posição por categoria | Concentração | Percentual / inteiro | Receita e DimProduto | Revisada estaticamente |
| Participação Receita Produto %; Ranking Produto Receita | 03 Ranking | Participação e ranking com desempate por ProductID | Concentração | Percentual / inteiro | Receita e DimProduto | Revisada estaticamente |
| Participação Receita Território %; Ranking Território Receita | 03 Ranking | Participação e posição territorial | Concentração | Percentual / inteiro | Receita e DimTerritorio | Revisada estaticamente |
| Participação Receita Cliente %; Ranking Cliente Receita | 03 Ranking | Participação e ranking com desempate por CustomerID | Concentração | Percentual / inteiro | Receita e DimCliente | Revisada estaticamente |
| Receita Acumulada Produtos; Participação Acumulada Produtos %; Percentual Acumulado de Produtos | 04 Pareto | Receita e entidades acumuladas em ordem determinística | Pareto de produtos | Valor / percentual | Ranking e receita | Revisada estaticamente; testar segmentações |
| Produtos para Atingir 80% da Receita; Percentual de Produtos para 80% da Receita; Classificação Pareto Produto | 04 Pareto | Quantidade, percentual da base e classe ABC | Limiar de concentração | Inteiro / percentual / texto | Pareto de produtos | Revisada estaticamente; testar linha de cruzamento |
| Receita Acumulada Clientes; Participação Acumulada Clientes %; Percentual Acumulado de Clientes | 04 Pareto | Receita e entidades acumuladas em ordem determinística | Pareto de clientes | Valor / percentual | Ranking e receita | Revisada estaticamente; testar segmentações |
| Clientes para Atingir 80% da Receita; Percentual de Clientes para 80% da Receita; Classificação Pareto Cliente | 04 Pareto | Quantidade, percentual da base e classe ABC | Limiar de concentração | Inteiro / percentual / texto | Pareto de clientes | Revisada estaticamente; testar linha de cruzamento |
| Receita Média Produto; Receita Mediana Produto; Desvio Padrão Receita Produto; Q1 Receita Produto; Q3 Receita Produto; IQR Receita Produto | 05 Estatística | Estatísticas populacionais no grão produto | Distribuição por produto | Neutro | Produto e receita | Revisada estaticamente |
| Limite Inferior Outlier Produto; Limite Superior Outlier Produto; Classificação Outlier Produto; Produtos Outliers Inferiores; Produtos Outliers Superiores | 05 Estatística | Limites de Tukey e contadores | Casos extremos por produto | Neutro / texto | Quartis por produto | Revisada estaticamente; outlier não é erro |
| Receita Média Território; Desvio Padrão Receita Território; Classificação Território vs Média | 05 Estatística | Estatísticas populacionais no grão território | Dispersão territorial | Neutro / texto | Território e receita | Revisada estaticamente |
| Receita Média Cliente; Receita Mediana Cliente; Q1 Receita Cliente; Q3 Receita Cliente; IQR Receita Cliente | 05 Estatística | Estatísticas populacionais no grão cliente | Distribuição por cliente | Neutro | Cliente e receita | Revisada estaticamente |
| Limite Inferior Outlier Cliente; Limite Superior Outlier Cliente; Classificação Outlier Cliente; Clientes Outliers Inferiores; Clientes Outliers Superiores | 05 Estatística | Limites de Tukey e contadores | Casos extremos por cliente | Neutro / texto | Quartis por cliente | Revisada estaticamente; outlier não é erro |

## Regra para remoção futura

Medidas legadas só podem ser removidas depois de migrar e verificar referências em consultas dos visuais, filtros, tooltips, formatação condicional, bookmarks, outras medidas e páginas ocultas. Nesta etapa elas foram mantidas como aliases para evitar quebra silenciosa.
