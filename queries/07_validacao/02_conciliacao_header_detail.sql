/* Objetivo: conciliar detalhe, SubTotal e TotalDue. Grão: pedido/resumo.
Universo: base completa. Receita: LineTotal versus SubTotal. Custo: não aplicável. Limitação: tolerância 0,01. */
USE AdventureWorks2022;
GO
WITH D AS (SELECT SalesOrderID,CONVERT(decimal(19,4),SUM(LineTotal)) SomaDetalhes FROM Sales.SalesOrderDetail GROUP BY SalesOrderID),
C AS (SELECT h.SalesOrderID,d.SomaDetalhes,CONVERT(decimal(19,4),h.SubTotal) SubTotal,CONVERT(decimal(19,4),d.SomaDetalhes-h.SubTotal) Diferenca
 FROM Sales.SalesOrderHeader h JOIN D d ON d.SalesOrderID=h.SalesOrderID)
SELECT COUNT(*) PedidosAvaliados,SUM(CASE WHEN ABS(Diferenca)>0.01 THEN 1 ELSE 0 END) PedidosDivergentes,
 MAX(ABS(Diferenca)) MaiorDivergencia,SUM(Diferenca) SomaDivergencias FROM C;

SELECT COUNT(*) PedidosAvaliados,
 SUM(CASE WHEN ABS(TotalDue-(SubTotal+TaxAmt+Freight))>0.01 THEN 1 ELSE 0 END) PedidosDivergentes,
 MAX(ABS(TotalDue-(SubTotal+TaxAmt+Freight))) MaiorDivergencia,
 SUM(TotalDue-(SubTotal+TaxAmt+Freight)) SomaDivergencias
FROM Sales.SalesOrderHeader;
GO
