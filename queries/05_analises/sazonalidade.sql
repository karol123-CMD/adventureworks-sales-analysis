/* Objetivo: série mensal densa, MoM, YoY e sazonalidade comparável.
Grão: mês calendário. Universo: padrão. Receita: após desconto, sem imposto/frete.
Custo: não utilizado. Limitação: anos incompletos são sinalizados e excluídos da síntese sazonal. */
USE AdventureWorks2022;
GO

WITH Meses AS (
 SELECT InicioMes,Ano,MesNumero,MAX(MesNome) MesNome,MAX(CONVERT(int,AnoCompleto)) AnoCompleto
 FROM dbo.vw_DimCalendario GROUP BY InicioMes,Ano,MesNumero
), Vendas AS (
 SELECT DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) InicioMes,
  SUM(ReceitaProdutosAposDesconto) Receita,COUNT(DISTINCT SalesOrderID) Pedidos
 FROM dbo.vw_FactVendas GROUP BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
), Serie AS (
 SELECT m.*,COALESCE(v.Receita,0) Receita,COALESCE(v.Pedidos,0) Pedidos
 FROM Meses m LEFT JOIN Vendas v ON v.InicioMes=m.InicioMes
), Comparada AS (
 SELECT a.*,pm.Receita ReceitaMesAnterior,py.Receita ReceitaAnoAnterior
 FROM Serie a LEFT JOIN Serie pm ON pm.InicioMes=DATEADD(month,-1,a.InicioMes)
 LEFT JOIN Serie py ON py.InicioMes=DATEADD(year,-1,a.InicioMes)
)
SELECT InicioMes,Ano,MesNumero,MesNome,AnoCompleto,Receita,Pedidos,
 CONVERT(decimal(19,4),Receita/NULLIF(Pedidos,0)) TicketMedio,
 CONVERT(decimal(19,6),(Receita-ReceitaMesAnterior)/NULLIF(ReceitaMesAnterior,0)) CrescimentoMoM,
 CONVERT(decimal(19,6),(Receita-ReceitaAnoAnterior)/NULLIF(ReceitaAnoAnterior,0)) CrescimentoYoY
FROM Comparada ORDER BY InicioMes;

WITH Meses AS (
    SELECT
        InicioMes,
        Ano,
        MesNumero,
        MAX(MesNome) AS MesNome,
        MAX(CONVERT(int, AnoCompleto)) AS AnoCompleto
    FROM dbo.vw_DimCalendario
    GROUP BY
        InicioMes,
        Ano,
        MesNumero
),
Vendas AS (
    SELECT
        DATEFROMPARTS(
            YEAR(OrderDate),
            MONTH(OrderDate),
            1
        ) AS InicioMes,
        SUM(ReceitaProdutosAposDesconto) AS Receita
    FROM dbo.vw_FactVendas
    GROUP BY
        DATEFROMPARTS(
            YEAR(OrderDate),
            MONTH(OrderDate),
            1
        )
),
Serie AS (
    SELECT
        m.InicioMes,
        m.Ano,
        m.MesNumero,
        m.MesNome,
        m.AnoCompleto,
        COALESCE(v.Receita, 0) AS Receita
    FROM Meses AS m
    LEFT JOIN Vendas AS v
        ON v.InicioMes = m.InicioMes
)
SELECT
    MesNumero,
    MAX(MesNome) AS MesNome,
    COUNT(DISTINCT Ano) AS AnosObservados,
    CONVERT(
        decimal(19, 4),
        AVG(CONVERT(decimal(19, 4), Receita))
    ) AS ReceitaMediaMensal,
    CONVERT(
        decimal(19, 4),
        STDEVP(CONVERT(float, Receita))
    ) AS DesvioPadraoPopulacional
FROM Serie
WHERE AnoCompleto = 1
GROUP BY MesNumero
ORDER BY MesNumero;
GO
