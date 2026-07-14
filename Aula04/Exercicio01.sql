USE woodcraftDjota;
GO

-- Exercício 1: Transação Segura com Deleção de Clientes --------------------------------------------------------------

DECLARE @IdCliente INT = 1;

BEGIN TRY
	BEGIN TRAN

		DELETE FROM [dbo].[Cliente]
			WHERE Id = @IdCliente;
		
		COMMIT TRAN
		PRINT 'Cliente deletado com sucesso.'
END TRY

BEGIN CATCH

	IF (@@TRANCOUNT > 0)
		ROLLBACK TRAN

	DECLARE @NumeroErro INT = ERROR_NUMBER(),
			@MensagemErro VARCHAR(500) = ERROR_MESSAGE();

	PRINT(CONCAT('Erro ao tentar excluir cliente de ID [', CAST(@IdCliente AS VARCHAR(10)), ']: ', @MensagemErro, '(Código do Erro: [', CAST(@NumeroErro AS VARCHAR(10)), ']). A transação foi desfeita.'));
END CATCH