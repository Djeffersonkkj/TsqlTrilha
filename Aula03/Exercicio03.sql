USE woodcraftDjota;
GO

-- Exercício 3: Stored Procedure de Cadastro Unificado de Pedidos -----------------------------------------------------

CREATE OR ALTER PROC [dbo].[sp_CadastrarNovoPedidoComItens]
	@IdCliente INT,
	@IdProduto INT,
	@Quantidade INT,
	@PrazoDias INT,
	@IdPedidoGerado INT OUTPUT
	AS
	/*
		Documentacao
		Arquivo Fonte................:	Exercicio03.sql
		Objetivo.....................:	Criar um novo pedido.
		Autor........................:	Djefferson dos Santos Lima.
		Data.........................:	13/07/2026
		Ex...........................:	
										BEGIN TRAN
											DECLARE @IdPedidoGeradoA INT,
													@Ret INT;

											 EXEC @Ret = [dbo].[sp_CadastrarNovoPedidoComItens]	@IdCliente = 1, 
																								@IdProduto = 1,
																								@Quantidade = -3,
																								@PrazoDias = 1,
																								@IdPedidoGerado = @IdPedidoGeradoA

											 PRINT @Ret
										ROLLBACK
		Retuns.......................:	0	- Sucesso
										-1	- Erro: Cliente não cadastrado.
										-2	- Erro: Produto não cadastrado.
										-3	- Erro: A quantidade informada deve ser maior que zero.
	*/
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[Cliente] WHERE Id = @IdCliente)
			BEGIN	
				PRINT 'Erro: Cliente não cadastrado.'
				RETURN -1
			END

		IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[Produto] WHERE Id = @IdProduto)
			BEGIN
				PRINT 'Erro: Produto não cadastrado.'
				RETURN -2
			END

		IF @Quantidade <= 0 
			BEGIN 
				PRINT 'Erro: A quantidade informada deve ser maior que zero.'
				RETURN -3
			END

		INSERT INTO [dbo].[Pedido] (IdCliente, DataPedido, DataPromessa)
			VALUES (
					@IdCliente, 
					GETDATE(),
					DATEADD(day, @PrazoDias, GETDATE())
			);

		SET @IdPedidoGerado = SCOPE_IDENTITY();

		INSERT INTO [dbo].[ItemPedido] (IdPedido, IdProduto, Quantidade)
			VALUES (@IdPedidoGerado, @IdProduto, @Quantidade)

		RETURN 0
	END
GO

