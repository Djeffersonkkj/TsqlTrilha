USE woodcraftDjota;
GO

-- Exercício 1: View de Painel Financeiro e de Expedição --------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[VW_ResumoPedidosClientes]
	AS
	SELECT	pe.Id AS IdPedido,
			cl.Nome AS NomeCliente,
			pe.DataPedido,
			COUNT(it.Id) AS QuantidadeItens,
			CASE
				WHEN pe.DataEntrega is not null  THEN 'Entregue'
				WHEN pe.DataEntrega is null AND pe.DataPromessa < GETDATE() THEN 'Atrasado'
				ELSE 'Em Andamento'
			END AS StatusPedido
		FROM [dbo].[Pedido] as pe
			JOIN [dbo].[Cliente] as cl
				ON pe.IdCliente = cl.Id
			JOIN [dbo].[ItemPedido] as it
				ON pe.Id = it.IdPedido
		GROUP BY pe.Id, cl.Nome, pe.DataPedido, pe.DataEntrega, pe.DataPromessa
GO

SELECT *
	FROM [dbo].[VW_ResumoPedidosClientes]