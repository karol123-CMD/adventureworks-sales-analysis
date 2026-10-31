# Design do dashboard AdventureWorks

Este documento descreve a identidade efetivamente usada no PBIX final. Propostas claras e alternativas de paleta da fase exploratória foram removidas para evitar conflito com a entrega.

## Identidade final

O dashboard usa fundo roxo profundo, superfícies violetas, texto quase branco, coral e lavanda como cores de dados. A referência canônica dos tokens está em [`../../assets/ux-ui/paleta_adventureworks_dark.md`](../../assets/ux-ui/paleta_adventureworks_dark.md).

| Papel | Cor |
|---|---|
| Fundo da página | `#090617` |
| Superfície principal | `#19132D` |
| Superfície secundária | `#21183A` |
| Cabeçalho escuro | `#100B22` |
| Bordas | `#38285E` |
| Grades e divisórias | `#43345F` |
| Texto principal | `#F7F5FC` |
| Texto secundário | `#B8B2C7` |
| Receita e série principal | `#FF756D` |
| Margem estimada e comparação secundária | `#A98CFF` |
| Resultado favorável | `#35C6A3` |
| Extremo de Tukey | `#D99A3B` |

## Semântica das cores

- Coral identifica receita e a série principal. Não significa resultado negativo.
- Lavanda identifica margem estimada e comparações secundárias.
- Verde é reservado a resultado comprovadamente favorável pela regra analítica.
- Âmbar identifica observações extremas pelo critério de Tukey, não erros.
- Branco é usado em indicadores neutros e valores sem julgamento.
- Na comparação territorial, coral marca valores acima da média e lavanda valores abaixo da média. Essa codificação descreve posição relativa e não transforma a média em meta.

## Hierarquia visual

Cada página segue uma leitura de cima para baixo:

1. cabeçalho com número, título, contexto e filtros;
2. cartões para os indicadores de síntese;
3. gráficos ou tabelas que respondem à pergunta central da página;
4. nota metodológica persistente sobre períodos parciais ou interpretação.

O canvas é 1280 x 720. Bordas e superfícies agrupam conteúdo sem competir com os dados. Espaços regulares separam filtros, cartões e áreas analíticas.

## Tipografia

O relatório combina Verdana nos elementos definidos pelo tema e Segoe UI em formatações específicas de visuais. Títulos usam peso mais forte; rótulos, eixos e legendas usam peso regular e texto secundário. Valores de KPI recebem maior escala, enquanto unidades e ressalvas permanecem visíveis no próprio canvas.

## Componentes

### Cartões

Apresentam um indicador por superfície, com rótulo, valor e unidade. Valores monetários usam `u.m.`. A margem é sempre identificada como estimada.

### Tabelas

Cabeçalhos escuros, divisórias discretas e números alinhados favorecem comparação. A rolagem é intencional quando o detalhe ultrapassa a área disponível; ela não é tratada como falha se colunas-chave, ordenação e leitura permanecerem preservadas.

### Filtros

Segmentadores ficam no cabeçalho, alinhados e com estado de seleção visível. Os campos variam conforme a página, sem alterar a lógica analítica do modelo.

### Gráficos

- Barras horizontais priorizam comparação entre categorias e territórios.
- Paretos combinam receita em coral e participação acumulada em lavanda, com eixos distintos.
- Dispersões preservam extremos e usam tamanho ou categoria apenas quando sustentados pelos campos do visual.
- A comparação territorial usa uma linha zero visual e cores divergentes, sem semântica automática de bom ou ruim.

## Acessibilidade

- Alto contraste entre texto principal e superfícies escuras.
- Texto secundário consistente para eixos e contexto.
- Títulos e unidades explícitos, sem depender somente de cor.
- Notas metodológicas visíveis nas cinco páginas.
- Identificação textual de média, margem estimada, períodos parciais e extremos de Tukey.
- Tooltips complementam a leitura, mas informações essenciais permanecem no canvas.

Contraste visual não constitui, sozinho, certificação de acessibilidade. Navegação por teclado, ordem de foco e leitura por tecnologia assistiva dependem de teste manual no Power BI Desktop e no ambiente de publicação escolhido.

## Wireframes e capturas finais

Os cinco arquivos em [`../../assets/ux-ui/wireframes/`](../../assets/ux-ui/wireframes/) são protótipos estruturais sem dados. Eles registram intenção de layout, não o estado executado do relatório.

As imagens em [`../../assets/screenshots/`](../../assets/screenshots/) são capturas finais do PBIX preenchido e prevalecem para apresentação de portfólio. Diferenças entre wireframe e captura refletem ajustes reais de conteúdo, densidade e legibilidade, sem tentativa de forçar equivalência artificial.

## Tema-base e overrides

O arquivo [`../../assets/ux-ui/tema_adventureworks_dark.json`](../../assets/ux-ui/tema_adventureworks_dark.json) usa propriedades verificadas no tema incorporado ao PBIX e no tema-base local. A formatação final combina esse tema com overrides individuais de cor, eixo, título, tooltip, tabela e formatação condicional.
