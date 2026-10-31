# Validação e conciliação SQL-DAX

## Estado final consolidado em 30/10/2026

SQL revalidado, PBIX atualizado e 37 das 98 medidas DAX corrigidas no modelo ativo. O arquivo foi salvo e reaberto. A conciliação estática SQL × DAX foi aprovada em 4.782 comparações, sem falhas (maior diferença absoluta 9.077e-7). As cinco páginas foram concluídas e revisadas; Top N, Paretos, YoY, filtros, interações, tooltips e a página estatística foram validados. Não permanecem visuais em carregamento indefinido. O gate técnico e o gate visual foram encerrados para a entrega local.

Esses resultados pertencem ao PBIX canônico e não implicam que todo o snapshot em `powerbi/Model/` esteja sincronizado. Em 30/10/2026, uma leitura TOM/ADOMD somente leitura confirmou e sincronizou no TMDL a expressão ativa de `Crescimento YoY %`; o estado dos demais objetos segue o escopo declarado no [`README do modelo`](../powerbi/Model/README.md).

## Integridade SQL - resultados registrados em 11/10/2026

Foram reexecutados os 18 scripts de leitura com sqlcmd e autenticação integrada, incluindo os sete validadores. Antes dos testes, somente `dbo.vw_FactVendas` recebeu `CREATE OR ALTER VIEW` para corrigir a fronteira de custo; tabelas de origem e as outras quatro views foram preservadas. Os resultados consolidados permanecem neste documento e nos scripts reproduzíveis; saídas temporárias de auditoria foram removidas da entrega. Os resultados de anomalia foram examinados, além do código de saída dos scripts.

| Validador | Resultado |
|---|---|
| 01 - universo | 121317 linhas, 31465 pedidos, todos status 5; período 2011-05-31 a 2014-06-30; sem lacunas mensais; 2011/2014 parciais |
| 02 - cabeçalho/detalhe | zero pedidos divergentes; soma das diferenças zero |
| 03 - dimensões | clientes 19820, produtos 504, territórios 10, calendário 1127; chaves únicas; zero órfãos |
| 04 - custo | 121253 linhas com um custo histórico; 64 sem correspondência e com fallback; nenhuma correspondência múltipla; zero intervalos inválidos, sobreposições ou horários não diários |
| 05 - KPIs | diferenças direta/view zero em receita, unidades, pedidos, clientes e produtos; datas iguais |
| 06 - contrato Power BI | cinco views presentes; 121317 chaves distintas de fato, sem duplicatas ou nulos nas chaves/valores testados |
| 07 - clientes | 19119 ativos, 840 outliers superiores, Top 10 7,21%; demais controles abaixo |

## Controles para comparação com DAX

Contexto global, medidas avaliadas no modelo ativo após refresh. Diferenças abaixo de 0,000001 u.m. decorrem da representação numérica; contagens e datas coincidem.

| Indicador | SQL | DAX | DAX − SQL |
|---|---:|---:|---:|
| Receita de Produtos / Receita Total | 109.846.381,399888 | 109.846.381,399887 | -0,0000006109 |
| Unidades Vendidas | 274.914 | 274.914 | 0 |
| Pedidos | 31.465 | 31.465 | 0 |
| Clientes Ativos | 19.119 | 19.119 | 0 |
| Produtos Vendidos | 266 | 266 | 0 |
| Custo Total Estimado | 97.288.600,8008 | 97.288.600,8008 | 0,0000004321 |
| Margem Bruta Estimada | 12.557.780,6004 | 12.557.780,6004 | 0,0000000056 |
| Receita Média Cliente | 5.745,404121 | 5.745,404122 | 0,0000005486 |
| Receita Mediana Cliente | 548,98 | 548,98 | 0 |
| Q1 Receita Cliente | 54,98 | 54,98 | 0 |
| Q3 Receita Cliente | 2.822,38605 | 2.822,38605 | 0 |
| Receita Top 10 Clientes | 7.922.046,383838 | 7.922.046,383838 | -0,0000000102 |
| Participação Top 10 Clientes | 0,072119 | 0,072119 | -0 |
| Clientes Outliers Superiores | 840 | 840 | 0 |
| Pareto clientes 1 / 10 / 20 | SQL: 0,007984 / 0,072119 / 0,132390 | 0,00798485 / 0,07211932 / 0,13239056 | 0 / 0 / 0 (proporções) |

## Conciliação DAX e cobertura dos testes

Em 11/10/2026 foram corrigidas 37 medidas, mantendo as 98 medidas do modelo. Os testes executaram 4.782 comparações automatizadas SQL × DAX e não encontraram falhas; tolerância de 1e-6 para medidas decimais, 1e-8 para proporções e igualdade exata para inteiros. O maior delta absoluto foi 9.077e-7.

Foram avaliados o total e os recortes 2013, 2014/Bikes, Southwest/Loja e 2013/Accessories; os 266 produtos vendidos por ProductID e NomeProduto; métricas temporais em 38 meses; cliente individual e produto individual, incluindo o comportamento do benchmark sob seleção de identidade. Produtos sem venda permanecem sem ranking. No cartão "YoY - último período válido", 2011, 2012 e 2014 ficam em branco; 2013 e a seleção "Todos" exibem 30,12%. Esse comportamento foi validado no PBIX; a expressão ativa de `Crescimento YoY %`, relida em 30/10/2026, distingue contexto filtrado e, em "Todos", calcula o ano completo mais recente. As consultas reproduzíveis permanecem nas camadas SQL e na documentação canônica; arquivos temporários de execução não integram a publicação.

A comparação territorial por TerritoryID fechou sem diferença nos dez grupos. A página regional, seus filtros e sua navegação foram conferidos na revisão final.

## Procedimento

1. Executar os sete scripts de [queries/07_validacao](../queries/07_validacao) na ordem numérica, após criar as views; os controles de KPIs e clientes estão em [05_conciliacao_kpis.sql](../queries/07_validacao/05_conciliacao_kpis.sql) e [07_controles_clientes.sql](../queries/07_validacao/07_controles_clientes.sql).
2. Abrir o PBIX principal, atualizar e limpar todos os filtros para os controles globais.
3. Comparar medidas canônicas e controles usando consultas DAX. O PBIX possui a consulta de controles `Consulta 2`; não é obrigatório criar uma página de validação.
4. Preencher a tabela com resultados efetivamente consultados, data e contexto. Inteiros/datas devem coincidir; para decimais, registrar diferença bruta e precisão utilizada. Não aceitar erro material apenas porque a exibição arredonda.
5. Repetir testes de quartis, Pareto e classificação com segmentadores e seleção de cliente; a igualdade no total não demonstra correção das interações.

O manifesto usa “Observação extrema superior” para a classe superior. Não filtrar por um rótulo antigo que deixe a tabela vazia. Valores monetários permanecem sem atribuição comprovada de moeda.

Exemplo de execução SQL na raiz do projeto:

```powershell
sqlcmd -S "SERVIDOR\INSTANCIA" -E -d AdventureWorks2022 -f 65001 -b -i "queries\07_validacao\05_conciliacao_kpis.sql"
```

Use o certificado apropriado à sua instância. Nenhuma senha precisa ser armazenada no projeto.

## Limites dos controles

Execução sem erro não basta: os resultados dos testes de anomalia precisam ser examinados. Os controles SQL não comprovam, por si sós, DAX ou visuais; nesta execução, a camada DAX foi também comparada de forma independente.

Pela regra inclusiva, o custo afetado por fallback soma **30692,8461 em 64 linhas**, com receita **37107,222000**. A regra anterior, exclusiva, produzia 80 fallbacks e custo total de 97290170,8653. A correção recupera histórico em 16 linhas e reduz o custo total em 1570,0645. A receita permanece 109846381,399888. Foram observadas 102 transições diárias contíguas e nenhuma sobreposição inclusiva entre os 395 históricos. Não apresentar a margem como custo histórico integralmente comprovado.

A margem da view soma valores arredondados a quatro casas por linha: **12557780,6004**. Subtrair o custo da receita sem esse arredondamento resulta em **12557780,599088**, diferença de **0,001312**. Esta diferença de precisão deve ser preservada na conciliação; a medida canônica soma a coluna da view.

O controle em [análise de territórios](../queries/04_kpis/analise_territorios.sql) agora compara Header/Detail diretamente com a fato por TerritoryID, incluindo grupos ausentes e território nulo. Os dez territórios tiveram diferença zero em linhas, receita, pedidos e clientes, sem grupo ausente. A página regional e seus filtros foram revisados após o ajuste do layout.

O diagnóstico de qualidade também passou a contar pedidos distintos nos indicadores `PedidosSemTerritorio` e `PedidosClienteNaoIdentificado`; antes contava linhas de itens. Ambos retornaram zero na base atual.
