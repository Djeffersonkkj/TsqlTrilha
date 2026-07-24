USE woodcraftDjota;
GO

-- Exercício 3: Procedure Transacional de Encerramento de Etapa e Atualização de Estoque Físico -----------------------

CREATE OR ALTER PROC sp_FinalizarEtapaFabricacao
	@IdHistoricoProducao INT
	AS
	/*
		Documentacao
		Arquivo Fonte...............:	Exercicio03.sql
		Autor.......................:	Djefferson dos Santos Lima
		Data Criacao................:	15/07/2026
		Exemplo.....................:
										BEGIN TRAN
											INSERT INTO [dbo].[HistoricoProducao] (IdEtapaFabricacao, IdItemPedido, DataInicio, Quantidade)
												VALUES (1, 1, GETDATE(), 2)

											DECLARE @IdHistoricoProducaoTeste INT = SCOPE_IDENTITY();

											SELECT * FROM [dbo].[HistoricoProducao]

											DECLARE @DataInicial DATETIME = GETDATE()

											EXEC sp_FinalizarEtapaFabricacao	@IdhistoricoProducao = @IdHistoricoProducaoTeste

											SELECT	DATEDIFF(ms, @DataInicial, GETDATE()) AS 'Tempo (ms)'

											SELECT * FROM [dbo].[HistoricoProducao]
										ROLLBACK TRAN
	*/
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[HistoricoProducao] WHERE @IdHistoricoProducao = Id)
					THROW 60001, 'Erro: Registro de histórico de produção não encontrado.', 1;

				IF EXISTS(SELECT TOP 1 1 FROM [dbo].[HistoricoProducao] WHERE @IdHistoricoProducao = Id AND DataTermino IS NOT NULL)
					THROW 60002, 'Erro: Esta etapa de fabricação já foi encerrada anteriormente.', 1;

				UPDATE [dbo].[HistoricoProducao]
					SET DataTermino = GETDATE()
					WHERE Id = @IdHistoricoProducao;

				DECLARE	@IdProduto INT,
						@EtapaConcluida INT,
						@Quantidade INT,
						@EtapaFinal INT;

				SELECT	@EtapaConcluida = ef.NumeroEtapa,
						@IdProduto = it.IdProduto,
						@Quantidade = hp.Quantidade
					FROM [dbo].[HistoricoProducao] as hp
						JOIN [dbo].[EtapaFabricacao] as ef
							ON hp.IdEtapaFabricacao = ef.Id
						JOIN [dbo].[ItemPedido] as it
							ON hp.IdItemPedido = it.Id
					WHERE hp.Id = @IdHistoricoProducao;

				SELECT	@EtapaFinal = MAX(NumeroEtapa)
					FROM [dbo].[EtapaFabricacao]
					WHERE IdProduto = @IdProduto;

				IF @EtapaConcluida = @EtapaFinal
					BEGIN
						UPDATE [dbo].[EstoqueProduto]
							SET QuantidadeFisica = QuantidadeFisica + @Quantidade;

						INSERT INTO [dbo].[MovimentacaoEstoqueProduto] (IdTipoMovimentacao, IdEstoqueProduto, DataMovimentacao, Quantidade)
							SELECT	1,
									IdProduto,
									GETDATE(),
									@Quantidade
								FROM [dbo].[EstoqueProduto];

						DECLARE @IdMovimentacaoEstoqueProduto INT;
							SET @IdMovimentacaoEstoqueProduto = SCOPE_IDENTITY();

						INSERT INTO [dbo].[AuditoriaEntradaEstoqueProduto] (IdHistoricoProducao, IdMovimentacaoEstoqueProduto)
							VALUES(@IdHistoricoProducao, @IdMovimentacaoEstoqueProduto);

						PRINT 'Móvel 100% finaliza. QUANTIADE ADICIONADA: ' + CAST(@Quantidade as VARCHAR(50));
					END
			COMMIT TRAN

		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT <> 0
				ROLLBACK TRAN

			DECLARE @NumeroErro INT = ERROR_NUMBER(),
			@MensagemErro VARCHAR(500) = ERROR_MESSAGE();

			PRINT(CONCAT('Erro: ', @MensagemErro, '(Código do Erro: [', CAST(@NumeroErro AS VARCHAR(10)), ']). A transação foi desfeita.'));
		END CATCH
	END


