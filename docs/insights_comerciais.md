# Insights comerciais - controles SQL em 11/10/2026

Resultados reproduzidos no AdventureWorks2022 e conciliados com o PBIX final. Universo: pedidos enviados (`Status=5`), quantidade e receita de itens positivas, após descontos, sem impostos e frete. Valores em unidades monetárias, sem conversão comprovada para reais.

## Concentração em clientes e produtos

No período de **31/05/2011 a 30/06/2014**, **1.607 dos 19.119 clientes ativos (8,41%)** são suficientes para atingir 80% da receita. Entre os produtos vendidos, são **64 de 266 (24,06%)**. O cálculo inclui a entidade que cruza o limiar, com desempate por chave.

A receita é mais concentrada em uma pequena parcela dos clientes do que dos produtos. Isso orienta a investigação da composição da carteira; não comprova risco de perda, fidelidade ou necessidade de uma ação comercial específica. Clientes sem venda e produtos sem venda não integram os denominadores.

Reproduzir o último resultado de [segmentação de clientes](../queries/04_kpis/segmentacao_clientes.sql) e [performance de produtos](../queries/04_kpis/performance_produtos.sql), sem filtros adicionais.

## Liderança regional com composições diferentes

No mesmo período completo da base, **Southwest** lidera com **24.184.609,60**, ou **22,02%** da receita, em **6.224 pedidos**. **Australia** registra mais pedidos (**6.843**), mas receita menor (**10.655.335,96**), com ticket de **1.557,11**, ante **3.885,70** em Southwest.

Volume de pedidos e receita contam histórias diferentes. A composição por tipo de cliente ajuda a contextualizar: Australia tem 6.718 pedidos de pessoas e 125 de lojas; Southwest tem 5.473 de pessoas e 751 de lojas. Isso descreve o mix observado, sem demonstrar causa, demanda potencial ou qualidade comercial. O território é o do pedido.

Reproduzir os dois primeiros resultados de [análise de territórios](../queries/04_kpis/analise_territorios.sql), sem segmentações. O terceiro resultado compara cada território com as tabelas de origem.

## Crescimento e margem não avançam juntos em todas as categorias

Comparando os anos completos **2012 e 2013**, a receita de **Components** passa de **3.880.757,95** para **5.612.935,34** (**+44,64%**), enquanto a margem bruta estimada em valor cai de **462.236,51** para **406.894,78**. A margem percentual passa de aproximadamente **11,91% para 7,25%**.

O crescimento de receita, isoladamente, não representa crescimento de rentabilidade. O resultado não identifica uma causa; alterações de mix, descontos e custos exigem investigação adicional. A margem é estimada, usa a vigência inclusiva de custo e permite fallback identificado. Os anos parciais de 2011 e 2014 não são usados nesta comparação anual.

Reproduzir em [margem versus crescimento](../queries/05_analises/margem_vs_crescimento.sql), nas linhas de `Components` para 2012 e 2013. O resultado já foi confrontado com a entrega local; uma atualização futura dos dados exige nova conciliação antes de atualizar as capturas ou a narrativa.
