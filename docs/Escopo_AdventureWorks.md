# Escopo - AdventureWorks

## Objetivo

Construir e documentar um dashboard de vendas sobre o AdventureWorks2022 com cinco páginas analíticas, camada SQL reproduzível, modelo dimensional, medidas DAX e validação entre SQL e Power BI.

## Entregas incluídas

- arquivo canônico `AdventureWorks_Dashboard.pbix`;
- cinco páginas concluídas: visão executiva, produtos, clientes, territórios e estatística;
- views analíticas em SQL e consultas de exploração, qualidade, KPIs, análises e validação;
- manifesto textual do modelo em `powerbi/Model/`;
- regras de negócio, mapeamento SQL - Power BI, dicionário DAX e validação SQL x DAX;
- cinco capturas finais e cinco wireframes preservados como protótipos;
- identidade visual escura e documentação de semântica.

## Universo e métricas

O universo padrão usa pedidos enviados (`Status = 5`), `LineTotal > 0` e `OrderQty > 0`. A receita corresponde aos itens após desconto, sem impostos e frete. O custo utiliza histórico vigente na data com fallback explícito para custo padrão atual. A margem bruta resultante é estimada.

Valores monetários são expressos em `u.m.`. Os anos 2011 e 2014 são parciais. Média é referência descritiva, concentração não comprova risco e extremos de Tukey não significam erro.

## Fora do escopo

- alteração dos dados-fonte do AdventureWorks;
- previsão, inferência causal ou recomendação automatizada;
- lucro líquido, despesas operacionais, metas comerciais ou orçamento;
- identificação de moeda não comprovada pela fonte;
- publicação pública, configuração de gateway ou distribuição do PBIX;
- afirmar que o manifesto TMDL constitui um projeto PBIP completo.

## Evidências

- [`regras_de_negocio.md`](regras_de_negocio.md)
- [`mapeamento_sql_powerbi.md`](mapeamento_sql_powerbi.md)
- [`dicionario_medidas_dax.md`](dicionario_medidas_dax.md)
- [`validacao_sql_dax.md`](validacao_sql_dax.md)
- [`insights_comerciais.md`](insights_comerciais.md)
- [capturas finais](../assets/screenshots/)
