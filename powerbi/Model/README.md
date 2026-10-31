# Manifesto textual do modelo

Este diretório é um snapshot TMDL para inspeção, revisão e rastreabilidade do modelo semântico. Ele não constitui um projeto PBIP completo e não substitui o arquivo [`AdventureWorks_Dashboard.pbix`](../../AdventureWorks_Dashboard.pbix), que é a entrega canônica.

A desserialização integral desta pasta pelo serializador TMDL local permanece impedida por uma incompatibilidade preexistente de propriedades `description` em `tables/Medidas.tmdl`; por isso o snapshot não deve ser tratado como pacote integralmente importável. Os dois objetos sincronizados nesta revisão foram comparados diretamente com a serialização oficial do modelo ativo.

O snapshot representa `FactVendas`, `DimCliente`, `DimProduto`, `DimTerritorio`, `DimCalendario`, `Medidas` e `Aparencia PoC`. A fato e as três dimensões de negócio são importadas pelo Power Query; `DimCalendario` é a tabela calculada em DAX ativa. Os relacionamentos são muitos-para-um e filtram das dimensões para a fato.

Estado de sincronização comprovado em 30/10/2026:

- `Crescimento YoY %` foi relida do modelo ativo por TOM/ADOMD somente leitura e sincronizada em `tables/Medidas.tmdl`;
- `Aparencia PoC` foi serializada pelo TMDL oficial a partir do modelo ativo e incluída em `tables/Aparencia PoC.tmdl`; é uma tabela calculada auxiliar de aparência, sem relacionamentos, com os modos `Claro`/`Escuro` e quatro medidas de cor;
- as demais 97 medidas de `Medidas.tmdl` conservam o snapshot cuja igualdade foi comprovada em 10/09/2026; não há comprovação de uma reexportação integral posterior.

O comportamento validado no PBIX para o cartão "YoY - último período válido" é: 2011, 2012 e 2014 em branco; 2013 e "Todos" em 30,12%. As dependências do modelo mostram `Aparencia PoC` apenas em suas próprias medidas auxiliares; ela não participa de relacionamentos nem de medidas comerciais. Referências de formatação ou filtros em visuais não são demonstradas pelo DMV do modelo e exigem conferência no Power BI Desktop.
