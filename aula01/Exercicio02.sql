USE woodcraftDjota;

-- Exercício 2: Notificação de Pedidos Atrasados ----------------------------------------------------------------------

DECLARE @PedidosAtrasados TABLE		(
										IdPedido INT, 
										NomeCliente VARCHAR(100),
										DiasAtraso INT
									);

INSERT INTO @PedidosAtrasados (IdPedido, NomeCliente, DiasAtraso)
	SELECT	pe.Id,
			cl.Nome,
			DATEDIFF(DAY,pe.DataPromessa, GETDATE())
		FROM [dbo].[Pedido] as pe WITH(NOLOCK)
			JOIN [dbo].[Cliente] as cl WITH(NOLOCK)
				ON pe.IdCliente = cl.Id
		WHERE pe.DataEntrega is null AND pe.DataPromessa < GETDATE();


SELECT * FROM @PedidosAtrasados;

WHILE EXISTS (SELECT TOP 1 1 FROM @PedidosAtrasados)
	BEGIN
		DECLARE @IdAtual INT = (SELECT TOP 1 Id FROM [dbo].[Pedido]);

		IF EXISTS (SELECT TOP 1 1 FROM @PedidosAtrasados WHERE IdPedido = @IdAtual )
			BEGIN
				DECLARE @NomeCliente VARCHAR(100),
						@DiasAtraso INT;

				SELECT	TOP 1
						@NomeCliente = pa.NomeCliente,
						@DiasAtraso = pa.DiasAtraso
					FROM @PedidosAtrasados as pa
					WHERE pa.IdPedido = @IdAtual;

				PRINT ('ALERTA: O Pedido ID [' + CAST(@IdAtual AS VARCHAR(10)) + '] do cliente [' + @NomeCliente + '] está atrasado em [' + CAST(@DiasAtraso AS VARCHAR(10)) + '] dias.')
			END

		DELETE FROM @PedidosAtrasados
			WHERE IdPedido = @IdAtual;
	END
