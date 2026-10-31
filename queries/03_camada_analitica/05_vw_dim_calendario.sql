/* Objetivo: calendário denso. Grão: data. Universo: limites dos pedidos enviados.
Receita/custo: não aplicável. Limitação: ainda não consumida pelo TMDL atual. */
USE AdventureWorks2022;
GO
CREATE OR ALTER VIEW dbo.vw_DimCalendario AS
WITH Limites AS (
 SELECT CONVERT(date,MIN(h.OrderDate)) AS DataMinima,CONVERT(date,MAX(h.OrderDate)) AS DataMaxima
 FROM Sales.SalesOrderHeader h WHERE h.Status=5
), Numeros AS (
 SELECT ROW_NUMBER() OVER (ORDER BY a.object_id,b.object_id)-1 AS n
 FROM sys.all_objects a CROSS JOIN sys.all_objects b
), Datas AS (
 SELECT DATEADD(day,n,DataMinima) AS Data,DataMinima,DataMaxima
 FROM Limites CROSS JOIN Numeros WHERE n<=DATEDIFF(day,DataMinima,DataMaxima)
)
SELECT CONVERT(date,Data) AS [Date],YEAR(Data) AS Ano,
 CONCAT('T',DATEPART(quarter,Data)) AS Trimestre,MONTH(Data) AS MesNumero,
 DATEFROMPARTS(YEAR(Data),MONTH(Data),1) AS InicioMes,YEAR(Data)*100+MONTH(Data) AS AnoMesNumero,
 CONCAT(YEAR(Data),'-',RIGHT(CONCAT('0',MONTH(Data)),2)) AS AnoMes,
 CASE MONTH(Data) WHEN 1 THEN N'Janeiro' WHEN 2 THEN N'Fevereiro' WHEN 3 THEN N'Março' WHEN 4 THEN N'Abril' WHEN 5 THEN N'Maio' WHEN 6 THEN N'Junho' WHEN 7 THEN N'Julho' WHEN 8 THEN N'Agosto' WHEN 9 THEN N'Setembro' WHEN 10 THEN N'Outubro' WHEN 11 THEN N'Novembro' ELSE N'Dezembro' END AS MesNome,
 CASE MONTH(Data) WHEN 1 THEN N'Jan' WHEN 2 THEN N'Fev' WHEN 3 THEN N'Mar' WHEN 4 THEN N'Abr' WHEN 5 THEN N'Mai' WHEN 6 THEN N'Jun' WHEN 7 THEN N'Jul' WHEN 8 THEN N'Ago' WHEN 9 THEN N'Set' WHEN 10 THEN N'Out' WHEN 11 THEN N'Nov' ELSE N'Dez' END AS MesAbrev,
 DAY(Data) AS Dia,
 CONVERT(bit,CASE WHEN DataMinima<=DATEFROMPARTS(YEAR(Data),1,1) AND DataMaxima>=DATEFROMPARTS(YEAR(Data),12,31) THEN 1 ELSE 0 END) AS AnoCompleto
FROM Datas;
GO
